-- Agents: APFS copy-on-write clones of a repository, created next to it as
-- `<parent>/<repo>--<name>`, where pi.nvim runs Pi inside a nono sandbox
-- through a workspace descriptor.

---@class Agent
---@field path string Agent checkout (its git root).
---@field source string Checkout the agent was cloned from.
---@field label string Name the agent was created with.

---@alias AgentPickerEntry
---| { kind: "source", path: string }
---| { kind: "agent", agent: Agent }

---@alias AgentSourceState
---| { kind: "ready", branch: string }
---| { kind: "dirty", status: string }
---| { kind: "off-default", branch: string?, default: string }
---| { kind: "unknown-default" }

NVAgents = {}

local fn = {}

local ffi = require("ffi")
pcall(
    ffi.cdef,
    [[
    int clonefile(const char *src, const char *dst, uint32_t flags);
    char *strerror(int errnum);
]]
)
local CLONE_NOFOLLOW = 0x0001

local ICON = "󰙅"
local SOURCE_ICON = NVTabs.editor_icon
local NONO_PROFILE = "pi-agent"
-- The only path an agent shares with its source, as a symlink.
local SHARED_PATH = ".project/.local"

function NVAgents.keymaps()
    K.map({ "<C-S-n>", "Create agent", fn.prompt_create, mode = { "n", "i", "v", "t" } })
    K.map({ "<D-g>w", "Show agent picker", fn.pick, mode = { "n", "i", "v", "t" } })
end

---
--- Lookup
---

--- The agent containing `path`, or nil when it isn't inside one.
---@param path string
---@return Agent?
function NVAgents.get(path)
    local root = fn.git_root(path)
    if not root then
        return nil
    end
    local source = fn.git(root, { "config", "--local", "--get", "agent.source" })
    if source.code ~= 0 then
        return nil
    end
    local label = fn.git(root, { "config", "--local", "--get", "agent.label" })
    return {
        path = root,
        source = vim.trim(source.stdout),
        label = label.code == 0 and vim.trim(label.stdout) or vim.fs.basename(root),
    }
end

---@param source string
---@return Agent[]
function fn.list(source)
    local parent = vim.fs.dirname(source)
    local prefix = vim.fs.basename(source) .. "--"
    local agents = {}
    for name, type in vim.fs.dir(parent) do
        if type == "directory" and vim.startswith(name, prefix) then
            local agent = NVAgents.get(vim.fs.joinpath(parent, name))
            if agent and agent.path == vim.fs.joinpath(parent, name) and agent.source == source then
                table.insert(agents, agent)
            end
        end
    end
    table.sort(agents, function(a, b)
        return a.path < b.path
    end)
    return agents
end

--- The checkout agents are created from: the current tab's repository, or
--- the source of the agent the tab is in.
---@return string? source, string? root
function fn.current_source()
    local root = fn.git_root(vim.fn.getcwd())
    if not root then
        return nil, nil
    end
    local agent = NVAgents.get(root)
    return agent and agent.source or root, root
end

---
--- Create
---

function fn.prompt_create()
    Snacks.input({ prompt = "Agent name: " }, function(name)
        if name and name ~= "" then
            fn.create(name)
        end
    end)
end

---@param name string
function fn.create(name)
    local source, root = fn.current_source()
    local relative_file = root and fn.relative_file(root)

    fn.async(function()
        if not source then
            fn.refuse("Not in a git repository")
        end
        ---@cast source string

        local normalized = fn.normalize_name(name)
        if normalized == "" then
            fn.refuse("Invalid agent name: " .. name)
        end

        local path = vim.fs.joinpath(vim.fs.dirname(source), vim.fs.basename(source) .. "--" .. normalized)
        if vim.uv.fs_lstat(path) then
            fn.refuse("Already exists: " .. path)
        end

        local state = fn.source_state(source)
        if state.kind ~= "ready" then
            fn.refuse("Can't create an agent: " .. fn.describe_source_state(source, state))
        end

        log.info("Updating " .. source .. "…")
        fn.git_ok(source, { "fetch" }, "git fetch failed in " .. source)
        fn.git_ok(source, { "merge", "--ff-only", "origin/" .. state.branch }, "Can't fast-forward " .. source)

        -- Created here, outside the cleanup below, so a failure never removes
        -- a directory this run didn't create.
        fn.mkdir_like(source, path)
        local ok, err = pcall(function()
            fn.clone(source, path)
            fn.setup({ source = source, path = path, label = name })
        end)
        if not ok then
            fn.exec({ "rm", "-rf", "--", path })
            error(err, 0)
        end

        fn.open_tab({ path = path, label = name }, relative_file)
    end)
end

--- Copy-on-write clone of `source` into the empty directory `path`, without
--- `SHARED_PATH`: each directory on the way to it is created, and its other
--- entries cloned whole with clonefile(2), which clones a directory tree in
--- one call.
---@param source string
---@param path string
function fn.clone(source, path)
    local segments = vim.split(SHARED_PATH, "/", { plain = true })

    ---@param src string
    ---@param dst string
    ---@param depth integer Index of the segment to skip in `src`.
    local function walk(src, dst, depth)
        for name, kind in vim.fs.dir(src) do
            local from, to = vim.fs.joinpath(src, name), vim.fs.joinpath(dst, name)
            if name ~= segments[depth] then
                fn.clonefile(from, to)
            elseif depth < #segments and kind == "directory" then
                fn.mkdir_like(from, to)
                walk(from, to, depth + 1)
            elseif depth < #segments then
                -- Not a real directory (e.g. a symlink): nothing to skip inside.
                fn.clonefile(from, to)
            end
        end
    end

    walk(source, path, 1)
end

--- Create directory `dst` with the permissions of directory `src`.
---@param src string
---@param dst string
function fn.mkdir_like(src, dst)
    local stat = assert(vim.uv.fs_stat(src))
    local ok, err = vim.uv.fs_mkdir(dst, bit.band(stat.mode, tonumber("7777", 8)))
    if not ok then
        fn.refuse("Couldn't create " .. dst .. ": " .. tostring(err))
    end
end

---@param src string
---@param dst string
function fn.clonefile(src, dst)
    if ffi.C.clonefile(src, dst, CLONE_NOFOLLOW) ~= 0 then
        fn.refuse("Couldn't clone " .. src .. ": " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end
end

---@param agent {source: string, path: string, label: string}
function fn.setup(agent)
    local shared = fn.link_shared(agent.source, agent.path)

    local descriptor = fn.descriptor_path()
    fn.write_descriptor(vim.fs.joinpath(agent.path, descriptor), shared)
    fn.exclude(agent.path, "/" .. descriptor)

    fn.git_ok(agent.path, { "config", "--local", "agent.source", agent.source }, "git config failed")
    fn.git_ok(agent.path, { "config", "--local", "agent.label", agent.label }, "git config failed")
end

--- Link the clone's `SHARED_PATH` to the source's, when the source has it.
---@param source string
---@param path string
---@return string? shared Absolute source path the agent links to.
function fn.link_shared(source, path)
    local shared = vim.fs.joinpath(source, SHARED_PATH)
    local stat = vim.uv.fs_stat(shared)
    if not stat or stat.type ~= "directory" then
        return nil
    end

    local target = vim.fs.joinpath(path, SHARED_PATH)
    -- Never touch anything reached through a symlinked ancestor.
    local real_path = assert(vim.uv.fs_realpath(path))
    local real_parent = vim.uv.fs_realpath(vim.fs.dirname(target))
    if not real_parent or not vim.startswith(real_parent, real_path .. "/") then
        fn.refuse("Can't link " .. SHARED_PATH .. ": its parent isn't a directory inside the agent")
    end

    local ok, err = vim.uv.fs_symlink(shared, target)
    if not ok then
        fn.refuse("Couldn't link " .. SHARED_PATH .. ": " .. tostring(err))
    end
    return shared
end

---@return string
function fn.descriptor_path()
    local descriptor = NVPi.opts.process.descriptor.path
    assert(type(descriptor) == "string" and descriptor ~= "", "NVPi.opts.process.descriptor.path is not set")
    return descriptor
end

---@param file string
---@param shared string? Source directory the agent links to.
function fn.write_descriptor(file, shared)
    local cmd = { "mise", "exec", "--", "nono", "run", "-s", "--profile", NONO_PROFILE, "--allow-cwd" }
    if shared then
        vim.list_extend(cmd, { "--allow", shared })
    end
    vim.list_extend(cmd, { "--", "pi", "--mode", "rpc" })

    local json = vim.json.encode({ process = { kind = "spawned", cmd = cmd } }, { indent = "    " })
    vim.fn.mkdir(vim.fs.dirname(file), "p")
    if vim.fn.writefile(vim.split(json, "\n"), file) ~= 0 then
        fn.refuse("Couldn't write " .. file)
    end
end

--- Add `pattern` to the repository's `.git/info/exclude`.
---@param repo string
---@param pattern string
function fn.exclude(repo, pattern)
    local file = fn.git_ok(repo, { "rev-parse", "--git-path", "info/exclude" }, "git rev-parse failed")
    if not vim.startswith(file, "/") then
        file = vim.fs.joinpath(repo, file)
    end
    local lines = vim.uv.fs_stat(file) and vim.fn.readfile(file) or {}
    if vim.tbl_contains(lines, pattern) then
        return
    end
    table.insert(lines, pattern)
    vim.fn.mkdir(vim.fs.dirname(file), "p")
    if vim.fn.writefile(lines, file) ~= 0 then
        fn.refuse("Couldn't write " .. file)
    end
end

---@param name string
---@return string
function fn.normalize_name(name)
    local result = name:lower()
    result = result:gsub("[%s_]+", "-")
    result = result:gsub("[^%w%-]", "")
    result = result:gsub("%-+", "-")
    result = result:gsub("^%-+", ""):gsub("%-+$", "")
    return result
end

---
--- Tabs
---

---@param root string
---@return string?
function fn.relative_file(root)
    local file = vim.fn.expand("%:p")
    if file ~= "" and vim.startswith(file, root .. "/") then
        return file:sub(#root + 2)
    end
    return nil
end

---@param agent {path: string, label: string}
---@param relative_file string?
function fn.open_tab(agent, relative_file)
    vim.cmd("tabnew")
    vim.cmd("tcd " .. vim.fn.fnameescape(agent.path))
    NVTabs.set_label({ icon = ICON, name = agent.label })

    if relative_file then
        local file = vim.fs.joinpath(agent.path, relative_file)
        if vim.fn.filereadable(file) == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(file))
        end
    end

    log.info("Agent: " .. agent.path)
    NVPi.open_float()
end

---@param path string
---@return integer?
function fn.find_tab(path)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab)) == path then
            return tab
        end
    end
    return nil
end

---@param agent Agent
---@param relative_file string?
function fn.switch_to(agent, relative_file)
    local tab = fn.find_tab(agent.path)
    if tab then
        vim.api.nvim_set_current_tabpage(tab)
    else
        fn.open_tab(agent, relative_file)
    end
end

--- Focus the source's tab, or open one when none is on it.
---@param source string
---@param relative_file string?
function fn.switch_to_source(source, relative_file)
    local tab = fn.find_tab(source)
    if tab then
        vim.api.nvim_set_current_tabpage(tab)
        return
    end
    vim.cmd("tabnew")
    vim.cmd("tcd " .. vim.fn.fnameescape(source))
    NVTabs.set_label({ icon = SOURCE_ICON, name = vim.fs.basename(source) })
    if relative_file then
        local file = vim.fs.joinpath(source, relative_file)
        if vim.fn.filereadable(file) == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(file))
        end
    end
end

---
--- Picker
---

function fn.pick()
    local source, root = fn.current_source()
    if not source then
        log.error("Not in a git repository")
        return
    end
    ---@cast root string
    local relative_file = fn.relative_file(root)

    local current_cwd = vim.fn.getcwd(-1, 0)
    ---@type AgentPickerEntry
    local source_entry = { kind = "source", path = source }
    -- `pinned` keeps the source first, above any score.
    local items = { { text = vim.fs.basename(source), entry = source_entry, pinned = true } }
    local current_idx = 1
    for _, agent in ipairs(fn.list(source)) do
        ---@type AgentPickerEntry
        local entry = { kind = "agent", agent = agent }
        table.insert(items, { text = agent.label, entry = entry, pinned = false })
        if agent.path == current_cwd then
            current_idx = #items
        end
    end

    Snacks.picker({
        title = "Agents",
        items = items,
        matcher = { fuzzy = false, regex = true },
        sort = { fields = { "pinned", "score:desc", "#text", "idx" } },
        on_show = function(picker)
            if current_idx > 1 then
                picker.list:move(current_idx, true)
            end
        end,
        format = function(item)
            local entry = item.entry ---@type AgentPickerEntry
            local icon, path
            if entry.kind == "source" then
                icon, path = SOURCE_ICON, entry.path
            elseif entry.kind == "agent" then
                icon, path = ICON, entry.agent.path
            end
            local tab = fn.find_tab(path)
            return { { icon .. " ", tab and "SnacksPickerIcon" or "Comment" }, { item.text } }
        end,
        confirm = function(picker, item)
            if item then
                picker:close()
                local entry = item.entry ---@type AgentPickerEntry
                if entry.kind == "source" then
                    fn.switch_to_source(entry.path, relative_file)
                elseif entry.kind == "agent" then
                    fn.switch_to(entry.agent, relative_file)
                end
            else
                local filter = picker.input:get()
                if filter and filter ~= "" then
                    picker:close()
                    fn.create(filter)
                end
            end
        end,
        preview = function(ctx)
            local entry = ctx.item.entry ---@type AgentPickerEntry
            if entry.kind == "source" then
                ctx.preview:set_lines({ "Path: " .. entry.path, "Source repository" })
            elseif entry.kind == "agent" then
                ctx.preview:set_lines({ "Path: " .. entry.agent.path, "Source: " .. entry.agent.source })
            end
        end,
    })
end

---
--- Close
---

---@param agent Agent
function NVAgents.close_tab(agent)
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
                fn.delete(agent)
            end
        end,
        layout = { preset = "select" },
    })
end

---@param agent Agent
function fn.delete(agent)
    local tab = fn.find_tab(agent.path)
    if tab then
        vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tab))
    end

    fn.async(function()
        fn.assert_deletable(agent)

        local unsaved = vim.tbl_filter(function(buffer)
            return buffer.modified
        end, fn.agent_buffers(agent.path))
        if #unsaved > 0 then
            local names = vim.tbl_map(function(buffer)
                return buffer.name
            end, unsaved)
            local message = "Unsaved changes in agent "
                .. agent.label
                .. ":\n"
                .. table.concat(fn.head(names, 15), "\n")
            if NVDialogs.confirm(message .. "\n\nDiscard and delete?", "&Yes\n&No", 2) ~= 1 then
                log.info("Kept agent: " .. agent.path)
                return
            end
        end

        if not fn.wait_for_pi(agent.path) then
            log.info("Kept agent: " .. agent.path)
            return
        end

        local leftovers = fn.leftovers(agent.path)
        if #leftovers > 0 then
            local message = "Agent " .. agent.label .. " isn't clean:\n" .. table.concat(leftovers, "\n")
            if NVDialogs.confirm(message .. "\n\nDelete anyway?", "&Yes\n&No", 2) ~= 1 then
                log.info("Kept agent: " .. agent.path)
                return
            end
        end

        -- Its files are about to go; buffers left open would point at nothing.
        for _, buffer in ipairs(fn.agent_buffers(agent.path)) do
            pcall(vim.api.nvim_buf_delete, buffer.buf, { force = true })
        end

        -- Remove the shared link as a link first; `rm -rf` doesn't follow symlinks either.
        local link = vim.fs.joinpath(agent.path, SHARED_PATH)
        local link_stat = vim.uv.fs_lstat(link)
        local linked = link_stat ~= nil and link_stat.type == "link"
        if linked then
            local ok, err = vim.uv.fs_unlink(link)
            if not ok then
                fn.refuse("Couldn't remove " .. link .. ": " .. tostring(err))
            end
        end
        fn.exec_ok({ "rm", "-rf", "--", agent.path }, "Couldn't delete " .. agent.path)

        local shared = vim.fs.joinpath(agent.source, SHARED_PATH)
        if linked and not vim.uv.fs_stat(shared) then
            log.error("Source's " .. SHARED_PATH .. " is missing after delete: " .. shared)
        end
        log.info("Deleted agent: " .. agent.path)

        fn.update_source(agent.source)
    end)
end

---@param agent Agent
function fn.assert_deletable(agent)
    local path, source = agent.path, agent.source
    local ok = vim.startswith(path, "/")
        and path ~= source
        and vim.fs.dirname(path) == vim.fs.dirname(source)
        and vim.startswith(vim.fs.basename(path), vim.fs.basename(source) .. "--")
        and vim.fn.isdirectory(vim.fs.joinpath(path, ".git")) == 1
    if not ok then
        fn.refuse("Refusing to delete " .. path .. ": not an agent of " .. source)
    end
end

---@class AgentBuffer
---@field buf integer
---@field name string Path relative to the agent.
---@field modified boolean

--- Buffers whose file is inside the agent.
---@param path string
---@return AgentBuffer[]
function fn.agent_buffers(path)
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
function fn.wait_for_pi(path)
    local real = vim.uv.fs_realpath(path) or path
    local deadline = vim.uv.now() + fn.stop_grace_ms(path) + 2000
    while true do
        local processes = fn.pi_processes(real)
        if #processes == 0 then
            return true
        end
        if vim.uv.now() >= deadline then
            local message = "Pi is still running in " .. path .. ":\n" .. table.concat(processes, "\n")
            return NVDialogs.confirm(message .. "\n\nDelete anyway?", "&Yes\n&No", 2) == 1
        end
        fn.sleep(250)
    end
end

-- pi.nvim's default and upper bound for `process.stop.grace_ms`.
local DEFAULT_STOP_GRACE_MS = 5000
local MAX_STOP_GRACE_MS = 60000

--- The grace period pi.nvim gives the agent's Pi to stop: the descriptor's
--- `process.stop.grace_ms` when it sets one, otherwise the `setup()` option.
---@param path string
---@return integer
function fn.stop_grace_ms(path)
    local configured = vim.tbl_get(NVPi.opts, "process", "stop", "grace_ms") or DEFAULT_STOP_GRACE_MS
    local file = vim.fs.joinpath(path, fn.descriptor_path())
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
function fn.pi_processes(real)
    local result = fn.exec({ "ps", "-axo", "pid=,ppid=,command=" })
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
                and padded:find(" --profile " .. NONO_PROFILE .. " ", 1, true)
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
        local cwd = fn.exec({ "lsof", "-w", "-a", "-p", pid, "-d", "cwd", "-Fn" })
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
function fn.leftovers(path)
    local lines = {}
    local status = fn.git(path, { "status", "--porcelain" })
    if status.code ~= 0 then
        table.insert(lines, "git status failed: " .. vim.trim(status.stderr))
    elseif vim.trim(status.stdout) ~= "" then
        table.insert(lines, "Uncommitted changes:")
        vim.list_extend(lines, fn.head(vim.split(vim.trim(status.stdout), "\n"), 15))
    end
    local unpushed = fn.git(path, { "log", "--branches", "--not", "--remotes", "--oneline" })
    if unpushed.code ~= 0 then
        table.insert(lines, "git log failed: " .. vim.trim(unpushed.stderr))
    elseif vim.trim(unpushed.stdout) ~= "" then
        table.insert(lines, "Unpushed commits:")
        vim.list_extend(lines, fn.head(vim.split(vim.trim(unpushed.stdout), "\n"), 15))
    end
    return lines
end

---@param source string
function fn.update_source(source)
    local state = fn.source_state(source)
    if state.kind ~= "ready" then
        log.warn("Source not updated, it may be behind: " .. fn.describe_source_state(source, state))
        return
    end
    local upstream = "origin/" .. state.branch
    local fetch = fn.git(source, { "fetch" })
    local merge = fetch.code == 0 and fn.git(source, { "merge", "--ff-only", upstream })
    if fetch.code ~= 0 or not merge or merge.code ~= 0 then
        local failed = fetch.code ~= 0 and fetch or merge --[[@as vim.SystemCompleted]]
        log.warn("Source " .. source .. " is behind " .. upstream .. ":\n" .. vim.trim(failed.stderr))
        return
    end
    log.info("Fast-forwarded " .. source .. " to " .. upstream)
end

---
--- Source state
---

---@param source string
---@return AgentSourceState
function fn.source_state(source)
    local status = fn.git_ok(source, { "status", "--porcelain" }, "git status failed in " .. source)
    if status ~= "" then
        return { kind = "dirty", status = status }
    end
    local default = fn.git(source, { "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
    if default.code ~= 0 then
        return { kind = "unknown-default" }
    end
    local default_branch = vim.trim(default.stdout):gsub("^origin/", "")
    local head = fn.git(source, { "symbolic-ref", "--quiet", "--short", "HEAD" })
    local branch = head.code == 0 and vim.trim(head.stdout) or nil
    if branch ~= default_branch then
        return { kind = "off-default", branch = branch, default = default_branch }
    end
    return { kind = "ready", branch = default_branch }
end

---@param source string
---@param state AgentSourceState
---@return string
function fn.describe_source_state(source, state)
    if state.kind == "ready" then
        return source .. " is clean on " .. state.branch
    elseif state.kind == "dirty" then
        return source .. " has uncommitted changes:\n" .. table.concat(fn.head(vim.split(state.status, "\n"), 15), "\n")
    elseif state.kind == "off-default" then
        return source .. " is on " .. (state.branch or "a detached HEAD") .. ", not " .. state.default
    elseif state.kind == "unknown-default" then
        return "can't tell the default branch of " .. source .. " (run `git remote set-head origin --auto`)"
    end
    error("unknown source state: " .. vim.inspect(state))
end

---
--- Process helpers
---

local Refusal = {}

--- Abort the running task with a message for the user.
---@param message string
function fn.refuse(message)
    error(setmetatable({ message = message }, Refusal), 0)
end

--- Run `body` as a coroutine, so `fn.exec` and `fn.sleep` don't block the UI.
---@param body fun()
function fn.async(body)
    local co = coroutine.create(function()
        local ok, err = xpcall(body, function(e)
            if getmetatable(e) == Refusal then
                return e
            end
            return debug.traceback(tostring(e), 2)
        end)
        if ok then
            return
        end
        if getmetatable(err) == Refusal then
            log.warn(err.message)
        else
            log.error(err)
        end
    end)
    fn.resume(co)
end

---@param co thread
function fn.resume(co, ...)
    local ok, err = coroutine.resume(co, ...)
    if not ok then
        log.error(debug.traceback(co, tostring(err)))
    end
end

--- Run a command; yields inside `fn.async`, blocks otherwise.
---@param cmd string[]
---@return vim.SystemCompleted
function fn.exec(cmd)
    local co, main = coroutine.running()
    if not co or main then
        return vim.system(cmd, { text = true }):wait()
    end
    vim.system(cmd, { text = true }, function(result)
        vim.schedule(function()
            fn.resume(co, result)
        end)
    end)
    return coroutine.yield()
end

---@param cmd string[]
---@param failure string
---@return string stdout
function fn.exec_ok(cmd, failure)
    local result = fn.exec(cmd)
    if result.code ~= 0 then
        local output = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
        fn.refuse(failure .. (output ~= "" and (":\n" .. output) or ""))
    end
    return vim.trim(result.stdout)
end

---@param dir string
---@param args string[]
---@return vim.SystemCompleted
function fn.git(dir, args)
    return fn.exec(vim.list_extend({ "git", "-C", dir }, args))
end

---@param dir string
---@param args string[]
---@param failure string
---@return string stdout
function fn.git_ok(dir, args, failure)
    return fn.exec_ok(vim.list_extend({ "git", "-C", dir }, args), failure)
end

---@param path string
---@return string?
function fn.git_root(path)
    local result = fn.git(path, { "rev-parse", "--show-toplevel" })
    return result.code == 0 and vim.trim(result.stdout) or nil
end

---@param ms integer
function fn.sleep(ms)
    local co = coroutine.running()
    vim.defer_fn(function()
        fn.resume(co)
    end, ms)
    coroutine.yield()
end

---@param list string[]
---@param n integer
---@return string[]
function fn.head(list, n)
    if #list <= n then
        return list
    end
    local result = vim.list_slice(list, 1, n)
    table.insert(result, ("… and %d more"):format(#list - n))
    return result
end
