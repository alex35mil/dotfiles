local M = {}

function M.get_buf_info(bufnr)
    return vim.fn.getbufinfo(bufnr)[1]
end

function M.is_buf_listed(bufnr)
    local buf = M.get_buf_info(bufnr)
    return buf.listed == 1
end

function M.get_listed_bufs(opts)
    local o = opts or {}
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })

    if o.sort_lastused then
        table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
    end

    return bufs
end

return M
