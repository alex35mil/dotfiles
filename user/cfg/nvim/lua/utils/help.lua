local M = {}

function M.is_help(bufnr)
    local bufnr = bufnr or vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    return filetype == "help"
end

return M
