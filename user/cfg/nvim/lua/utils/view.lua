local M = {}

function M.get_tab_windows()
    local tabs = vim.fn.gettabinfo()
    local current_tab = vim.fn.tabpagenr()

    local windows

    for _, tab in ipairs(tabs) do
        if tab.tabnr == current_tab then
            windows = tab.windows
            break
        end
    end

    return windows
end

function M.get_tab_windows_without_filetree()
    local filetree = require "utils/filetree"

    local windows = M.get_tab_windows()

    local result = {}

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        if not filetree.is_tree(buf) then
            table.insert(result, win)
        end
    end

    return result
end

return M
