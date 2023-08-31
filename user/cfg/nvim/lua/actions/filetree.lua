local M = {}

function M.open_file_tree()
    vim.cmd "Neotree source=filesystem position=float toggle=true reveal=true"
end

function M.open_git_tree()
    vim.cmd "Neotree source=git_status position=float toggle=true reveal=true"
end

return M
