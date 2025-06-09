NVFS = {}

local format = vim.fn.fnamemodify

---@param options {capitalize: boolean}
---@return string
function NVFS.root(options)
    local opts = options or { capitalize = false }

    local cwd = vim.fn.getcwd()
    local root = format(cwd, ":t")

    if opts.capitalize then
        return root:upper()
    else
        return root
    end
end

---@param loc string
---@return string
function NVFS.relative_path(loc)
    return format(loc, ":.")
end

---@param loc string
---@return string
function NVFS.filename(loc)
    return format(loc, ":t")
end

---@param loc string
---@return string
function NVFS.filestem(loc)
    return format(loc, ":t:r")
end

---@param loc string
---@param fmt "absolute" | "relative" | "filename" | "filestem"
---@return string | nil
function NVFS.format(loc, fmt)
    if fmt == "absolute" then
        return loc
    elseif fmt == "relative" then
        return NVFS.relative_path(loc)
    elseif fmt == "filename" then
        return NVFS.filename(loc)
    elseif fmt == "filestem" then
        return NVFS.filestem(loc)
    else
        log.error("Invalid path format: " .. fmt)
        return nil
    end
end
