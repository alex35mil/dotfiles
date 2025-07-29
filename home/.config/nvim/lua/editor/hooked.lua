local title = "Hooked"

NVHooked = { data = nil }

local fn = {}

function NVHooked.keymaps()
    K.map({
        NVKeyRemaps["<D-h>"],
        "Show hooked buffers",
        NVHooked.show,
        mode = { "n", "i", "v", "t" },
    })

    K.map({
        "<C-h>",
        "Hook/unhook a buffer",
        NVHooked.toggle,
        mode = { "n", "i", "v" },
    })
end

---@param level "debug" | "info" | "warn" | "error"
---@param message string
function fn.log(level, message)
    local opts = { title = title }

    if level == "debug" then
        log.debug(message, opts)
    elseif level == "info" then
        log.info(message, opts)
    elseif level == "warn" then
        log.warn(message, opts)
    elseif level == "error" then
        log.error(message, opts)
    else
        log.error("Invalid log level: " .. level)
    end
end

---@return string
function fn.get_cache_path()
    local project_root = vim.fn.getcwd()
    local cache_dir = vim.fn.stdpath("cache") .. "/hooked"
    vim.fn.mkdir(cache_dir, "p")

    -- Use MD5 hash of project path as filename to avoid path separator issues
    local hash = vim.fn.sha256(project_root):sub(1, 16)
    return cache_dir .. "/" .. hash .. ".json"
end

---@return boolean, table
function fn.load()
    local cache_path = fn.get_cache_path()
    if vim.fn.filereadable(cache_path) == 0 then
        return true, {}
    end

    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(cache_path), "\n"))

    if ok then
        NVHooked.data = data
    else
        fn.log("error", "Failed to load hooked buffers")
    end

    return ok, data
end

function fn.save(data)
    local cache_path = fn.get_cache_path()
    local result = vim.fn.writefile({ vim.json.encode(data) }, cache_path)

    if result == -1 then
        fn.log("error", "Failed to save hooked buffers")
        return false
    else
        NVHooked.data = data
        return true
    end
end

---@param files string[]
function NVHooked.hook(files)
    local loaded, hooked = fn.load()

    if not loaded then
        fn.log("error", "Failed to load hooked buffers")
        return
    end

    local added = {}

    for _, filepath in ipairs(files) do
        if not hooked[filepath] then
            hooked[filepath] = vim.empty_dict()
            table.insert(added, filepath)
        else
            fn.log("warn", "Already hooked: " .. NVFS.relative_path(filepath))
        end
    end

    if #added > 0 then
        local saved = fn.save(hooked)

        if not saved then
            return
        end

        if #added == 1 then
            fn.log("info", "󰓎  Hooked " .. NVFS.filename(added[1]))
        else
            fn.log("info", "󰓎  Hooked " .. #added .. " files")
        end
    end
end

---@param bufid BufID?
function NVHooked.toggle(bufid)
    bufid = bufid or vim.api.nvim_get_current_buf()
    if bufid == 0 then
        bufid = vim.api.nvim_get_current_buf()
    end

    local filepath = vim.api.nvim_buf_get_name(bufid)
    if filepath == "" then
        fn.log("warn", "Only saved files can be hooked")
        return
    end

    local loaded, hooked = fn.load()

    if not loaded then
        fn.log("error", "Failed to load hooked buffers")
        return
    end

    if hooked[filepath] then
        hooked[filepath] = nil

        local saved = fn.save(hooked)

        if not saved then
            return
        end

        fn.log("info", "󱕩  Unhooked " .. NVFS.filename(filepath))
        return false -- Removed
    else
        hooked[filepath] = vim.empty_dict()

        local saved = fn.save(hooked)

        if not saved then
            return
        end

        fn.log("info", "󰓎  Hooked " .. NVFS.filename(filepath))
        return true -- Added
    end
end

function NVHooked.show()
    local loaded, _ = fn.load()

    if not loaded then
        fn.log("error", "Failed to load hooked data")
        return
    elseif vim.tbl_count(NVHooked.data) == 0 then
        fn.log("warn", "No hooked buffers found")
        return
    end

    local STATE = {
        show_full_paths = false,
    }

    local function build_item_list()
        local items = {}

        local function get_display_filename(filepath)
            local filename = vim.fn.fnamemodify(filepath, ":t")
            local index_files = { "mod.rs", "init.lua", "index.js", "index.ts" }

            for _, special in ipairs(index_files) do
                if filename == special then
                    local parent_dir = vim.fn.fnamemodify(filepath, ":h:t")
                    return parent_dir .. "/" .. filename
                end
            end

            return filename
        end

        -- First pass: collect display filenames and detect duplicates
        local display_filenames = {}
        local filename_counts = {}

        for filepath, _ in pairs(NVHooked.data) do
            local display_filename = get_display_filename(filepath)
            display_filenames[filepath] = display_filename
            filename_counts[display_filename] = (filename_counts[display_filename] or 0) + 1
        end

        -- Convert hooked buffers to picker items
        for filepath, _ in pairs(NVHooked.data) do
            local display_filename = display_filenames[filepath]
            local has_duplicates = filename_counts[display_filename] > 1
            local is_directory = vim.fn.isdirectory(filepath) == 1

            table.insert(items, {
                text = display_filename,
                file = filepath,
                display_filename = display_filename,
                has_duplicates = has_duplicates,
                is_directory = is_directory,
                show_full_paths = STATE.show_full_paths,
            })
        end

        -- Sort alphabetically by full absolute path
        table.sort(items, function(a, b)
            return a.file < b.file
        end)

        return items
    end

    local function format(item)
        local icon = nil
        local icon_hl = "SnacksPickerFile"

        if item.is_directory then
            icon = "󰉋 "
            icon_hl = "SnacksPickerDirectory"
        else
            local devicons = require("nvim-web-devicons")
            local filename = vim.fn.fnamemodify(item.file, ":t")
            local ext = vim.fn.fnamemodify(item.file, ":e")
            local devicon, devicon_hl = devicons.get_icon(filename, ext, { default = true })
            if devicon then
                icon = devicon .. " "
                icon_hl = devicon_hl or "SnacksPickerFile"
            end
        end

        local parts = {}

        if icon then
            table.insert(parts, { icon, icon_hl })
        end

        table.insert(parts, { " " .. item.text, "SnacksPickerFile" })

        if item.show_full_paths or item.has_duplicates then
            local full_path = vim.fn.fnamemodify(item.file, ":~:.")
            table.insert(parts, { "  " .. full_path, "SnacksPickerDir" })
        end

        return parts
    end

    local function build_layout(items)
        -- Calculate width and height
        local max_width = 0
        for _, item in ipairs(items) do
            local row = format(item)
            local line_width = 0
            for _, part in ipairs(row) do
                line_width = line_width + #part[1]
            end
            max_width = math.max(max_width, line_width)
        end

        max_width = max_width + 2 -- borders

        local editor_width = vim.o.columns
        local desired_width = math.min(max_width, math.floor(editor_width * 0.8))
        local width = math.max(desired_width, 40)

        local editor_height = vim.o.lines
        local content_height = #items + 4 -- items + borders + input
        local max_height = math.floor(editor_height * 0.8)
        local height = math.min(content_height, max_height)

        return {
            layout = {
                box = "vertical",
                width = width,
                height = height,
                relative = "editor",
                position = "float",
                backdrop = false,
            },
            hidden = { "preview" },
            cycle = false,
        }
    end

    local initial_items = build_item_list()
    local initial_layout = build_layout(initial_items)

    Snacks.picker({
        title = "󰓎 " .. title,
        items = initial_items,
        layout = initial_layout,
        format = format,
        finder = build_item_list,
        win = {
            input = {
                keys = {
                    ["<M-f>"] = { "hooked_show_full_paths", mode = { "n", "i" } },
                    ["<CR>"] = { "hooked_open", mode = { "n", "i" } },
                    ["<D-BS>"] = { "hooked_delete", mode = { "n", "i" } },
                    ["<D-x>"] = { "hooked_delete_all", mode = { "n", "i" } },
                },
            },
        },
        actions = {
            hooked_open = function(picker, item)
                if item then
                    if not item.is_directory then
                        picker:action("confirm")
                    else
                        Snacks.explorer({
                            cwd = item.file,
                            auto_close = true,
                            on_show = function(_)
                                vim.cmd("stopinsert")
                            end,
                        })
                    end
                end
            end,
            hooked_show_full_paths = function(picker, _)
                STATE.show_full_paths = not STATE.show_full_paths
                picker:find({
                    refresh = true,
                    on_done = function()
                        local updated_items = picker:items()
                        local updated_layout = build_layout(updated_items)
                        picker:set_layout(updated_layout)
                    end,
                })
            end,
            hooked_delete = function(picker, item)
                local current_idx = item.idx

                local updated_data = vim.tbl_deep_extend("error", {}, NVHooked.data)

                updated_data[item.file] = nil

                local saved = fn.save(updated_data)

                if not saved then
                    return
                end

                if vim.tbl_count(NVHooked.data) == 0 then
                    picker:close()
                else
                    picker:find({
                        refresh = true,
                        on_done = function()
                            -- Set selection to next item, or last item if we deleted the last one
                            local new_total = picker:count()
                            if new_total > 0 then
                                local new_idx = current_idx
                                if current_idx > new_total then
                                    new_idx = new_total
                                end
                                picker.list:move(new_idx, true, true)
                            end
                        end,
                    })
                end
            end,
            hooked_delete_all = function(picker, _)
                local saved = fn.save(vim.empty_dict())

                if not saved then
                    return
                end

                picker:close()
            end,
        },
    })
end
