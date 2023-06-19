local M = {}

function M.yank(text)
    vim.fn.setreg("+", text)
end

return M
