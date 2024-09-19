NVFS = {}

local format = vim.fn.fnamemodify

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

function NVFS.relative_path(loc)
    return format(loc, ":.")
end

function NVFS.filename(loc)
    return format(loc, ":t")
end

function NVFS.filestem(loc)
    return format(loc, ":t:r")
end

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
        vim.api.nvim_err_writeln("Invalid path format: " .. fmt)
        return nil
    end
end
