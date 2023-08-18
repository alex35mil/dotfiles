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

function M.are_sidenotes_visible()
    local nnp = require "plugins.no-neck-pain"
    local buffers = require "utils.buffers"

    local windows = M.get_tab_windows()

    for _, win in ipairs(windows) do
        local bufnr = vim.api.nvim_win_get_buf(win)
        local buf = buffers.get_buf_info(bufnr)

        local bufname = buf.name
        local sidenotes_left = nnp.scratchpad_filename .. "-left." .. nnp.scratchpad_filetype
        local sidenotes_right = nnp.scratchpad_filename .. "-right." .. nnp.scratchpad_filetype

        if string.sub(bufname, - #sidenotes_left) == sidenotes_left or string.sub(bufname, - #sidenotes_right) == sidenotes_right then
            return true
        end
    end

    return false
end

function M.get_tab_windows_with_listed_buffers(opts)
    local opts = opts or {}
    local incl_help = opts.incl_help or false

    local buffers = require "utils.buffers"
    local help = require "utils.help"

    local windows = M.get_tab_windows()

    local result = {}

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local incl_if_help = incl_help and help.is_help(buf)

        if buffers.is_buf_listed(buf) or incl_if_help then
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
