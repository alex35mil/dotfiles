local M = {}

function M.rename_tab(name)
    vim.cmd("LualineRenameTab " .. name)
end

return M
