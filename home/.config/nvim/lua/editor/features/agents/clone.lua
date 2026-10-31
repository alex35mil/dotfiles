-- Creating an agent checkout: an APFS copy-on-write clone of the source,
-- linked to the source's `SHARED_PATH`, with a pi.nvim workspace descriptor
-- that runs Pi inside a nono sandbox.

local util = require("editor.features.agents.util")

local M = {}

local ffi = require("ffi")
pcall(
    ffi.cdef,
    [[
    int clonefile(const char *src, const char *dst, uint32_t flags);
    char *strerror(int errnum);
]]
)
local CLONE_NOFOLLOW = 0x0001

M.NONO_PROFILE = "pi-agent"
-- The only path an agent shares with its source, as a symlink.
M.SHARED_PATH = ".project/.local"

--- Copy-on-write clone of `source` into the empty directory `path`, without
--- `SHARED_PATH`: each directory on the way to it is created, and its other
--- entries cloned whole with clonefile(2), which clones a directory tree in
--- one call.
---@param source string
---@param path string
function M.clone(source, path)
    local segments = vim.split(M.SHARED_PATH, "/", { plain = true })

    ---@param src string
    ---@param dst string
    ---@param depth integer Index of the segment to skip in `src`.
    local function walk(src, dst, depth)
        for name, kind in vim.fs.dir(src) do
            local from, to = vim.fs.joinpath(src, name), vim.fs.joinpath(dst, name)
            if name ~= segments[depth] then
                M.clonefile(from, to)
            elseif depth < #segments and kind == "directory" then
                M.mkdir_like(from, to)
                walk(from, to, depth + 1)
            elseif depth < #segments then
                -- Not a real directory (e.g. a symlink): nothing to skip inside.
                M.clonefile(from, to)
            end
        end
    end

    walk(source, path, 1)
end

--- Create directory `dst` with the permissions of directory `src`.
---@param src string
---@param dst string
function M.mkdir_like(src, dst)
    local stat = assert(vim.uv.fs_stat(src))
    local ok, err = vim.uv.fs_mkdir(dst, bit.band(stat.mode, tonumber("7777", 8)))
    if not ok then
        util.refuse("Couldn't create " .. dst .. ": " .. tostring(err))
    end
end

---@param src string
---@param dst string
function M.clonefile(src, dst)
    if ffi.C.clonefile(src, dst, CLONE_NOFOLLOW) ~= 0 then
        util.refuse("Couldn't clone " .. src .. ": " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end
end

---@param agent {source: string, path: string, label: string}
function M.setup(agent)
    local shared = M.link_shared(agent.source, agent.path)

    local descriptor = M.descriptor_path()
    M.write_descriptor(vim.fs.joinpath(agent.path, descriptor), shared)
    M.exclude(agent.path, "/" .. descriptor)

    util.git_ok(agent.path, { "config", "--local", "agent.source", agent.source }, "git config failed")
    util.git_ok(agent.path, { "config", "--local", "agent.label", agent.label }, "git config failed")
end

--- Link the clone's `SHARED_PATH` to the source's, when the source has it.
---@param source string
---@param path string
---@return string? shared Absolute source path the agent links to.
function M.link_shared(source, path)
    local shared = vim.fs.joinpath(source, M.SHARED_PATH)
    local stat = vim.uv.fs_stat(shared)
    if not stat or stat.type ~= "directory" then
        return nil
    end

    local target = vim.fs.joinpath(path, M.SHARED_PATH)
    -- Never touch anything reached through a symlinked ancestor.
    local real_path = assert(vim.uv.fs_realpath(path))
    local real_parent = vim.uv.fs_realpath(vim.fs.dirname(target))
    if not real_parent or not vim.startswith(real_parent, real_path .. "/") then
        util.refuse("Can't link " .. M.SHARED_PATH .. ": its parent isn't a directory inside the agent")
    end

    local ok, err = vim.uv.fs_symlink(shared, target)
    if not ok then
        util.refuse("Couldn't link " .. M.SHARED_PATH .. ": " .. tostring(err))
    end
    return shared
end

---@return string
function M.descriptor_path()
    local descriptor = NVPi.opts.process.descriptor.path
    assert(type(descriptor) == "string" and descriptor ~= "", "NVPi.opts.process.descriptor.path is not set")
    return descriptor
end

---@param file string
---@param shared string? Source directory the agent links to.
function M.write_descriptor(file, shared)
    local cmd = { "mise", "exec", "--", "nono", "run", "-s", "--profile", M.NONO_PROFILE, "--allow-cwd" }
    if shared then
        vim.list_extend(cmd, { "--allow", shared })
    end
    vim.list_extend(cmd, { "--", "pi", "--mode", "rpc" })

    local json = vim.json.encode({ process = { kind = "spawned", cmd = cmd } }, { indent = "    " })
    vim.fn.mkdir(vim.fs.dirname(file), "p")
    if vim.fn.writefile(vim.split(json, "\n"), file) ~= 0 then
        util.refuse("Couldn't write " .. file)
    end
end

--- Add `pattern` to the repository's `.git/info/exclude`.
---@param repo string
---@param pattern string
function M.exclude(repo, pattern)
    local file = util.git_ok(repo, { "rev-parse", "--git-path", "info/exclude" }, "git rev-parse failed")
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
        util.refuse("Couldn't write " .. file)
    end
end

return M
