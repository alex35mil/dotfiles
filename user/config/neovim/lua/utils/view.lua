local M = {}

M.window_picker_keys = "UHKMETJWNSABCDFGILOPQRVXYZ1234567890"

function M.get_tab_windows(options)
    local opts

    if options and options.incl_sidenotes ~= nil then
        opts = { skip_sidenotes = not options.incl_sidenotes }
    else
        opts = { skip_sidenotes = true }
    end

    local tabs = vim.fn.gettabinfo()
    local current_tab = vim.fn.tabpagenr()

    local windows

    for _, tab in ipairs(tabs) do
        if tab.tabnr == current_tab then
            windows = tab.windows
            break
        end
    end

    if not windows then return nil end

    local result = {}

    local sidenotes = M.get_sidenotes()

    for _, winid in ipairs(windows) do
        if not M.is_window_floating(winid) then
            if opts.skip_sidenotes and sidenotes ~= nil then
                if winid ~= sidenotes.left and winid ~= sidenotes.right then
                    table.insert(result, winid)
                end
            else
                table.insert(result, winid)
            end
        end
    end

    return result
end

function M.reposition_windows(opts)
    local windows = M.get_tab_windows()

    if #windows == 2 then
        vim.cmd "wincmd r"
    elseif #windows > 2 then
        local action = opts.action
        if action == "move" then
            vim.cmd "WinShift"
        elseif action == "swap" then
            vim.cmd "WinShift swap"
        else
            vim.api.nvim_err_writeln "Unexpected windows action"
        end
    else
        print "No windows to rotate"
        return
    end
end

function M.get_sidenotes()
    ---@diagnostic disable-next-line
    local nnp = _G.NoNeckPain

    if not nnp then return nil end

    local state = nnp.state

    if not state then return nil end

    local current_tab = vim.api.nvim_get_current_tabpage()

    local tab = nil

    for _, t in ipairs(state.tabs) do
        if t.id == current_tab then
            tab = t
            break
        end
    end

    if not tab then return nil end

    local win = tab.wins.main

    return {
        left = win.left,
        right = win.right,
    }
end

function M.are_sidenotes_visible()
    local sidenotes = M.get_sidenotes()

    if not sidenotes then return false end

    return sidenotes.left ~= nil or sidenotes.right ~= nil
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

function M.is_other_window_with_buffer_exists(tab_windows, current_win, current_buf)
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

function M.is_window_floating(winid)
    local win = vim.api.nvim_win_get_config(winid)
    return win.relative ~= ""
end

return M