local M = {}

function M.open_diff()
    vim.cmd "DiffviewOpen"
end

function M.hide_current_diff()
    vim.cmd "DiffviewClose"
end

function M.current_diff()
    local dv = require "diffview.lib"

    local current_diff = dv.get_current_view()

    return current_diff
end

function M.inactive_diff()
    local dv = require "diffview.lib"

    local tabs = vim.api.nvim_list_tabpages()

    for _, tabpage in ipairs(tabs) do
        for _, view in ipairs(dv.views) do
            if view.tabpage == tabpage then
                return tabpage
            end
        end
    end

    return nil
end

function M.ensure_hidden()
    local current_diff = M.current_diff()

    if current_diff ~= nil then
        M.hide_current_diff()
    end

    local inactive_diff_tab = M.inactive_diff()

    if inactive_diff_tab ~= nil then
        vim.api.nvim_command("tabclose " .. inactive_diff_tab)
    end
end

return M
