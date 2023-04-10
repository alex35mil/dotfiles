local M = {}

function M.is_tree(buf)
    local tree = require "nvim-tree.view"
    local tree_buf = tree.get_bufnr()

    return tree_buf == buf
end

function M.is_active()
    local active_buf = vim.api.nvim_get_current_buf()
    return M.is_tree(active_buf)
end

function M.close()
    vim.cmd "NvimTreeClose"
end

return M
