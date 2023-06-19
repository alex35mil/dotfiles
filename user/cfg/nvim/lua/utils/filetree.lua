local M = {}

local function get_active_trees()
    local trees = {}

    for _, source in ipairs(require("neo-tree").config.sources) do
        local state = require("neo-tree.sources.manager").get_state(source)
        if state and state.bufnr then
            trees[state.bufnr] = state
        end
    end

    return trees
end

function M.is_tree(buf)
    local trees = get_active_trees()
    return trees[buf] ~= nil
end

function M.is_active()
    local active_buf = vim.api.nvim_get_current_buf()
    return M.is_tree(active_buf)
end

function M.open()
    vim.cmd "NeoTreeShow"
end

function M.close()
    vim.cmd "NeoTreeClose"
end

function M.toggle()
    vim.cmd "NeoTreeShowToggle"
end

function M.ensure_opened()
    local trees = get_active_trees()

    if next(trees) == nil then
        M.open()
    end
end

function M.ensure_hidden()
    local trees = get_active_trees()

    if next(trees) ~= nil then
        M.close()
    end
end

return M
