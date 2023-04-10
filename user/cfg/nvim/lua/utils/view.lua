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

function M.get_tab_windows_with_listed_buffers()
    local buffers = require "utils.buffers"

    local windows = M.get_tab_windows()

    local result = {}

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)

        if buffers.is_buf_listed(buf) then
            table.insert(result, win)
        end
    end

    return result
end

function M.is_other_window_with_buffer(tab_windows, current_win, current_buf)
    local result = false

    for _, win in ipairs(tab_windows) do
        if win ~= current_win then
            local win_buf = vim.api.nvim_win_get_buf(win)
            if current_buf == win_buf then
                return true
            end
        end
    end

    return result
end

return M
