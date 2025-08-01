---@class Watcher
---@field tracked_items table<Filepath, {ino: INode, type: FSEntry}>
---@field inode_map table<INode, Filepath>
---@field watch_root string
---@field timer uv.uv_timer_t | nil
---@field move_handler fun(old_path: Filepath, new_path: Filepath, item_type: FSEntry)
---@field delete_handler fun(path: Filepath, item_type: FSEntry) Handler for delete events
---@field poll_interval_ms number
---@field clock string
local Watcher = {}

Watcher.__index = Watcher

local DEBUG = false

---@param message string
---@param data table | nil
local function debug(message, data)
    if not DEBUG then
        return
    end

    local msg = message:gsub('"', '\\"')
    if data then
        print(string.format("DEBUG: %s %s", msg, vim.inspect(data)))
    else
        print(string.format("DEBUG: %s", msg))
    end
end

---@param options {on_move: fun(old_path: Filepath, new_path: Filepath, item_type: FSEntry), on_delete: fun(path: Filepath, item_type: FSEntry), poll_interval_ms?: number}
---@return boolean, Watcher | nil
function Watcher:new(options)
    local obj = {
        tracked_items = {},
        inode_map = {},
        watch_root = vim.fn.getcwd(),
        timer = nil,
        move_handler = options.on_move,
        delete_handler = options.on_delete,
        poll_interval_ms = options and options.poll_interval_ms or 1000, -- ms
        clock = "n:watchman_init_" .. os.time(),
    }
    setmetatable(obj, self)

    local ok = obj:setup_watch()

    if ok then
        return true, obj
    else
        return false, nil
    end
end

---@param path Filepath
---@return boolean
function Watcher:track(path)
    local stat = vim.uv.fs_stat(path)
    if not stat then
        log.error("Path does not exist: " .. path)
        return false
    end

    local item_type = self:detect_type(path)
    if not item_type then
        log.error("Cannot determine type for path: " .. path)
        return false
    end

    -- Ensure path is absolute and within our watch root
    local abs_path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
    if not abs_path:sub(1, #self.watch_root) == self.watch_root then
        log.warn(abs_path .. " is outside watch root " .. self.watch_root)
    end

    self.tracked_items[abs_path] = {
        ino = stat.ino,
        type = item_type,
    }

    self.inode_map[stat.ino] = abs_path

    debug("Tracking", { path = abs_path, type = item_type, inode = stat.ino })

    return true
end

---@param path Filepath
function Watcher:untrack(path)
    local item = self.tracked_items[path]
    if item then
        self.inode_map[item.ino] = nil
        self.tracked_items[path] = nil
        debug("Untracked", { path = path })
    end
end

---@param path Filepath
---@return FSEntry | nil
function Watcher:detect_type(path)
    local stat = vim.uv.fs_stat(path)
    if not stat then
        return nil
    end

    if stat.type == "file" then
        return "file"
    elseif stat.type == "directory" then
        return "directory"
    end
    return nil
end

---@return boolean
function Watcher:setup_watch()
    local watch_cmd = string.format("watchman watch '%s'", self.watch_root)
    local result = vim.fn.system(watch_cmd)

    if vim.v.shell_error ~= 0 then
        log.error("Failed to setup Watchman: " .. result)
        return false
    end

    debug("Setup Watchman for: " .. self.watch_root)

    self.timer = vim.uv.new_timer()
    self.timer:start(0, self.poll_interval_ms, function()
        vim.schedule(function()
            self:poll()
        end)
    end)

    return true
end

function Watcher:poll()
    local query = {
        "query",
        self.watch_root,
        {
            expression = { "allof", { "anyof", { "type", "f" }, { "type", "d" } } },
            fields = { "name", "exists", "new", "ino", "type" },
            since = self.clock,
        },
    }

    local query_json = vim.json.encode(query)
    local cmd = string.format("echo '%s' | watchman -j", query_json:gsub("'", "'\"'\"'"))

    vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            if data and #data > 0 then
                local response_str = table.concat(data, "")
                if response_str:len() > 0 then
                    local ok, response = pcall(vim.json.decode, response_str)
                    if ok and response then
                        self:process_watchman_response(response)
                    else
                        log.warn("Failed to decode Watchman response: " .. response_str)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 then
                local output = table.concat(data, " ")
                if output:len() > 0 then
                    log.warn("Watchman error: " .. table.concat(data, " "))
                end
            end
        end,
        stdout_buffered = true,
    })
end

---@param response {files: {name: string, exists: boolean, ino: number, type: string}[], clock: string}
function Watcher:process_watchman_response(response)
    if not response.files then
        return
    end

    if response.clock then
        self.clock = response.clock
    end

    if #response.files == 0 then
        return
    end

    -- First pass: build a map of all files in this response by inode
    local entries_by_inode = {}
    for _, file in ipairs(response.files) do
        if file.ino then
            entries_by_inode[file.ino] = entries_by_inode[file.ino] or {}
            table.insert(entries_by_inode[file.ino], file)
        end
    end

    debug("Watchman response", response)

    -- Process changes by inode groups
    for ino, entries in pairs(entries_by_inode) do
        -- Skip if we're not tracking this inode
        if not self.inode_map[ino] then
            goto continue
        end

        local tracked_path = self.inode_map[ino]
        local tracked_item = self.tracked_items[tracked_path]

        if not tracked_item then
            goto continue
        end

        local exists_entries = {}
        local not_exists_entries = {}

        for _, entry in ipairs(entries) do
            if entry.exists then
                table.insert(exists_entries, entry)
            else
                table.insert(not_exists_entries, entry)
            end
        end

        -- Case 1: Entry moved (inode exists at a new location)
        if #exists_entries > 0 then
            for _, entry in ipairs(exists_entries) do
                local new_path = self.watch_root .. "/" .. entry.name
                new_path = vim.fn.fnamemodify(new_path, ":p"):gsub("/$", "")

                if new_path ~= tracked_path then
                    self.tracked_items[new_path] = tracked_item
                    self.tracked_items[tracked_path] = nil
                    self.inode_map[ino] = new_path

                    self.move_handler(tracked_path, new_path, tracked_item.type)
                    break
                end
            end
        -- Case 2: Entry doesn't exist anymore
        elseif #not_exists_entries > 0 then
            -- Check if this is a nvim backup dance
            local backup_ext = vim.opt.backupext:get()
            local is_nvim_backup = false

            for _, entry in ipairs(not_exists_entries) do
                if entry.name:sub(-#backup_ext) == backup_ext then
                    -- This is a backup file - check if original still exists
                    local original_name = entry.name:sub(1, -#backup_ext - 1)
                    local original_path = self.watch_root .. "/" .. original_name
                    original_path = vim.fn.fnamemodify(original_path, ":p"):gsub("/$", "")

                    if original_path == tracked_path then
                        local stat = vim.uv.fs_stat(tracked_path)
                        if stat and stat.ino ~= ino then
                            debug("Nvim backup detected", {
                                path = tracked_path,
                                ino_change = {
                                    from = ino,
                                    to = stat.ino,
                                },
                            })

                            -- Update inode mapping
                            self.inode_map[ino] = nil
                            self.inode_map[stat.ino] = tracked_path
                            tracked_item.ino = stat.ino

                            is_nvim_backup = true
                            break
                        end
                    end
                end
            end

            if not is_nvim_backup then
                -- This is an actual delete
                debug("Delete detected", { path = tracked_path, ino = ino })

                self.tracked_items[tracked_path] = nil
                self.inode_map[ino] = nil

                self.delete_handler(tracked_path, tracked_item.type)
            end
        end

        ::continue::
    end

    debug("Current state", self)
end

function Watcher:cleanup()
    if self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
    end

    local cmd = string.format("watchman watch-del '%s'", self.watch_root)
    vim.fn.system(cmd)

    self.tracked_items = {}
    self.inode_map = {}

    debug("Watcher cleanup complete")
end

return Watcher
