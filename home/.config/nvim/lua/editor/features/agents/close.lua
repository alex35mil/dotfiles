-- Closing an agent's tab, or deleting the agent.

local util = require("editor.features.agents.util")
local source_mod = require("editor.features.agents.source")
local clone = require("editor.features.agents.clone")
local tabs = require("editor.features.agents.tabs")

local M = {}

---@param agent Agent
function M.close_tab(agent)
    Snacks.picker({
        title = "Close: " .. agent.label,
        items = {
            { text = "Delete agent", action = "delete" },
            { text = "Close tab", action = "close-tab" },
        },
        format = function(item)
            return { { " ", "SnacksPickerIcon" }, { item.text } }
        end,
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end
            if item.action == "close-tab" then
                vim.cmd("tabclose")
            elseif item.action == "delete" then
                M.delete(agent)
            end
        end,
        layout = { preset = "select" },
    })
end

---@param agent Agent
function M.delete(agent)
    local tab = tabs.find(agent.path)
    if tab then
        vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tab))
    end

    util.async(function()
        M.assert_deletable(agent)

        local unsaved = vim.tbl_filter(function(buffer)
            return buffer.modified
        end, M.agent_buffers(agent.path))
        if #unsaved > 0 then
            local names = vim.tbl_map(function(buffer)
                return buffer.name
            end, unsaved)
            local message = "Unsaved changes in agent "
                .. agent.label
                .. ":\n"
                .. table.concat(util.head(names, 15), "\n")
            if NVDialogs.confirm(message .. "\n\nDiscard and delete?", "&Yes\n&No", 2) ~= 1 then
                log.info("Kept agent: " .. agent.path)
                return
            end
        end

        if not M.wait_for_pi(agent.path) then
            log.info("Kept agent: " .. agent.path)
            return
        end

        local leftovers = M.leftovers(agent.path)
        if #leftovers > 0 then
            local message = "Agent " .. agent.label .. " isn't clean:\n" .. table.concat(leftovers, "\n")
            if NVDialogs.confirm(message .. "\n\nDelete anyway?", "&Yes\n&No", 2) ~= 1 then
                log.info("Kept agent: " .. agent.path)
                return
            end
        end

        -- Its files are about to go; buffers left open would point at nothing.
        for _, buffer in ipairs(M.agent_buffers(agent.path)) do
            pcall(vim.api.nvim_buf_delete, buffer.buf, { force = true })
        end

        -- Remove the shared link as a link first; `rm -rf` doesn't follow symlinks either.
        local link = vim.fs.joinpath(agent.path, clone.SHARED_PATH)
        local link_stat = vim.uv.fs_lstat(link)
        local linked = link_stat ~= nil and link_stat.type == "link"
        if linked then
            local ok, err = vim.uv.fs_unlink(link)
            if not ok then
                util.refuse("Couldn't remove " .. link .. ": " .. tostring(err))
            end
        end
        util.exec_ok({ "rm", "-rf", "--", agent.path }, "Couldn't delete " .. agent.path)

        local shared = vim.fs.joinpath(agent.source, clone.SHARED_PATH)
        if linked and not vim.uv.fs_stat(shared) then
            log.error("Source's " .. clone.SHARED_PATH .. " is missing after delete: " .. shared)
        end
        log.info("Deleted agent: " .. agent.path)

        source_mod.update(agent.source)
    end)
end

---@param agent Agent
function M.assert_deletable(agent)
    local path, source = agent.path, agent.source
    local ok = vim.startswith(path, "/")
        and path ~= source
        and vim.fs.dirname(path) == vim.fs.dirname(source)
        and vim.startswith(vim.fs.basename(path), vim.fs.basename(source) .. "--")
        and vim.fn.isdirectory(vim.fs.joinpath(path, ".git")) == 1
    if not ok then
        util.refuse("Refusing to delete " .. path .. ": not an agent of " .. source)
    end
end

---@class AgentBuffer
---@field buf integer
---@field name string Path relative to the agent.
---@field modified boolean

--- Buffers whose file is inside the agent.
---@param path string
---@return AgentBuffer[]
function M.agent_buffers(path)
    local prefix = path .. "/"
    local buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.startswith(name, prefix) then
            table.insert(buffers, { buf = buf, name = name:sub(#prefix + 1), modified = vim.bo[buf].modified })
        end
    end
    return buffers
end

--- Wait until the agent's Pi launch has exited (pi.nvim stops it on tab
--- close). Asks when it's still running after its stop grace period.
---@param path string
---@return boolean proceed
function M.wait_for_pi(path)
    local real = vim.uv.fs_realpath(path) or path
    local deadline = vim.uv.now() + M.stop_grace_ms(path) + 2000
    while true do
        local processes = M.pi_processes(real)
        if #processes == 0 then
            return true
        end
        if vim.uv.now() >= deadline then
            local message = "Pi is still running in " .. path .. ":\n" .. table.concat(processes, "\n")
            return NVDialogs.confirm(message .. "\n\nDelete anyway?", "&Yes\n&No", 2) == 1
        end
        util.sleep(250)
    end
end

-- pi.nvim's default and upper bound for `process.stop.grace_ms`.
local DEFAULT_STOP_GRACE_MS = 5000
local MAX_STOP_GRACE_MS = 60000

--- The grace period pi.nvim gives the agent's Pi to stop: the descriptor's
--- `process.stop.grace_ms` when it sets one, otherwise the `setup()` option.
---@param path string
---@return integer
function M.stop_grace_ms(path)
    local configured = vim.tbl_get(NVPi.opts, "process", "stop", "grace_ms") or DEFAULT_STOP_GRACE_MS
    local file = vim.fs.joinpath(path, clone.descriptor_path())
    local ok, descriptor = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(file), "\n"))
    end)
    local grace = ok and type(descriptor) == "table" and vim.tbl_get(descriptor, "process", "stop", "grace_ms")
    -- Same bounds pi.nvim accepts; anything else makes pi.nvim refuse the descriptor.
    if type(grace) == "number" and grace == math.floor(grace) and grace >= 0 and grace <= MAX_STOP_GRACE_MS then
        return grace
    end
    return configured
end

--- The agent's Pi launch: `nono run --profile <NONO_PROFILE>` processes (as
--- written by the descriptor) whose working directory is in the agent, and
--- every process under them.
---@param real string
---@return string[] processes as "<pid> <command>"
function M.pi_processes(real)
    local result = util.exec({ "ps", "-axo", "pid=,ppid=,command=" })
    local commands, children, launches = {}, {}, {}
    for _, line in ipairs(vim.split(result.stdout or "", "\n", { trimempty = true })) do
        local pid, ppid, command = line:match("^%s*(%d+)%s+(%d+)%s+(.*)$")
        if pid then
            commands[pid] = command
            children[ppid] = children[ppid] or {}
            table.insert(children[ppid], pid)
            -- Only the nono executable itself, not a shell whose command text mentions it.
            local program, args = command:match("^(%S+)(.*)$")
            local padded = args .. " "
            if
                vim.fs.basename(program) == "nono"
                and vim.startswith(padded, " run ")
                and padded:find(" --profile " .. clone.NONO_PROFILE .. " ", 1, true)
            then
                table.insert(launches, pid)
            end
        end
    end

    local processes = {}
    local function add(pid)
        table.insert(processes, pid .. " " .. commands[pid]:sub(1, 120))
        for _, child in ipairs(children[pid] or {}) do
            add(child)
        end
    end
    for _, pid in ipairs(launches) do
        local cwd = util.exec({ "lsof", "-w", "-a", "-p", pid, "-d", "cwd", "-Fn" })
        local dir = (cwd.stdout or ""):match("\nn([^\n]+)")
        if dir and (dir == real or vim.startswith(dir, real .. "/")) then
            add(pid)
        end
    end
    return processes
end

--- Uncommitted changes and unpushed commits, as lines to show.
---@param path string
---@return string[]
function M.leftovers(path)
    local lines = {}
    local status = util.git(path, { "status", "--porcelain" })
    if status.code ~= 0 then
        table.insert(lines, "git status failed: " .. vim.trim(status.stderr))
    elseif vim.trim(status.stdout) ~= "" then
        table.insert(lines, "Uncommitted changes:")
        vim.list_extend(lines, util.head(vim.split(vim.trim(status.stdout), "\n"), 15))
    end
    local unpushed = util.git(path, { "log", "--branches", "--not", "--remotes", "--oneline" })
    if unpushed.code ~= 0 then
        table.insert(lines, "git log failed: " .. vim.trim(unpushed.stderr))
    elseif vim.trim(unpushed.stdout) ~= "" then
        table.insert(lines, "Unpushed commits:")
        vim.list_extend(lines, util.head(vim.split(vim.trim(unpushed.stdout), "\n"), 15))
    end
    return lines
end

return M
