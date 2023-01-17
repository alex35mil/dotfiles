local M = {}

function M.send_keys(keys)
    local tc = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(tc, "x", false)
end

return M
