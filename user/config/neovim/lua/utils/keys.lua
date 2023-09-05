local M = {}

function M.send_in_x_mode(keys)
    local tc = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(tc, "x", false)
end

function M.send_in_t_mode(keys)
    vim.api.nvim_feedkeys(keys, "t", false)
end

return M
