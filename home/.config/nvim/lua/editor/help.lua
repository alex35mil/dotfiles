NVHelp = {}

---@param bufnr BufID?
---@return boolean
function NVHelp.is_help(bufnr)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    return filetype == "help"
end
