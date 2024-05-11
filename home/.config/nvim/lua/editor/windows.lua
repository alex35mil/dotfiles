local M = {}
local m = {}

M.default_width = 140
M.window_picker_keys = "UHKMETJWNSABCDFGILOPQRVXYZ1234567890"

function M.keymaps()
    K.map { "<D-n>", "Create new buffer in the current window", "<Cmd>enew<CR>", mode = { "n", "v", "i" } }
    K.mapseq { "<Leader>nh", "Create new buffer in a horizontal split", "<Cmd>new<CR>", mode = "n" }
    K.mapseq { "<Leader>nn", "Create new buffer in a vertical split", "<Cmd>vnew<CR>", mode = "n" }

    K.map { "<S-Left>", "Move to window on the left", "<Cmd>wincmd h<CR>", mode = { "n", "v", "t" } }
    K.map { "<S-Down>", "Move to window below", "<Cmd>wincmd j<CR>", mode = { "n", "v", "t" } }
    K.map { "<S-Up>", "Move to window above", "<Cmd>wincmd k<CR>", mode = { "n", "v", "t" } }
    K.map { "<S-Right>", "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "v", "t" } }

    K.map { "<D-C-S-Left>", "Move window to the left", function() m.reposition_windows({ action = "move_left" }) end, mode = "n" }
    K.map { "<D-C-S-Right>", "Move window to the right", function() m.reposition_windows({ action = "move_right" }) end, mode = "n" }
    K.map { "<D-C-S-Up>", "Move window up", function() m.reposition_windows({ action = "move_up" }) end, mode = "n" }
    K.map { "<D-C-S-Down>", "Move window down", function() m.reposition_windows({ action = "move_down" }) end, mode = "n" }

    K.mapseq { "<Leader>ws", "Swap windows", function() m.reposition_windows({ action = "swap" }) end, mode = "n" }

    K.map { "<M-S-Up>", "Increase window width", function() m.change_window_width("up") end, mode = "n" }
    K.map { "<M-S-Down>", "Decrease window width", function() m.change_window_width("down") end, mode = "n" }
    K.map { "<M-S-Right>", "Increase window height", function() m.change_window_height("up") end, mode = "n" }
    K.map { "<M-S-Left>", "Decrease window height", function() m.change_window_height("down") end, mode = "n" }

    K.map { "<D-Esc>", "Justify layout", m.justify_layout, mode = "n" }
    K.map { "<D-S-Esc>", "Reset layout", m.reset_layout, mode = "n" }
end

function M.is_window_floating(winid)
    local win = vim.api.nvim_win_get_config(winid)
    return win.relative ~= ""
end

function M.get_floating_tab_windows()
    local windows = m.get_tab_windows()

    if not windows then return nil end

    local result = {}

    for _, winnr in ipairs(windows) do
        if M.is_window_floating(winnr) then
            table.insert(result, winnr)
        end
    end

    return result
end

function M.get_tab_windows_with_listed_buffers(options)
    local opts = vim.tbl_extend("keep", options, {
        incl_help = false,
        incl_sidenotes = false,
    })

    local windows = m.get_normal_tab_windows({ incl_sidenotes = opts.incl_sidenotes })

    if not windows then return nil end

    local buffers = require "editor.buffers"
    local help = require "editor.help"

    local result = {}

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local incl_if_help = opts.incl_help and help.is_help(buf)

        if buffers.is_buf_listed(buf) or incl_if_help then
            table.insert(result, win)
        end
    end

    return result
end

-- Private

function m.reposition_windows(opts)
    local nnp = require "plugins.no-neck-pain"

    local action = opts.action

    local windows = m.get_normal_tab_windows({ incl_sidenotes = false })
    local sidenotes_visible = nnp.are_sidenotes_visible()

    if #windows == 2 and action == "swap" then
        if sidenotes_visible then nnp.disable() end
        vim.cmd "wincmd r"
        if sidenotes_visible then nnp.enable() end
    elseif #windows > 1 then
        local winshift = require "plugins.winshift"

        if action == "swap" then
            winshift.swap()
        elseif action == "move_left" then
            nnp.disable()
            winshift.move_left()
            nnp.enable()
        elseif action == "move_right" then
            nnp.disable()
            winshift.move_right()
            nnp.enable()
        elseif action == "move_up" then
            nnp.disable()
            winshift.move_up()
            nnp.enable()
        elseif action == "move_down" then
            nnp.disable()
            winshift.move_down()
            nnp.enable()
        else
            vim.api.nvim_err_writeln "Unexpected windows action"
        end
    else
        print "No windows to rotate"
        return
    end
end

function m.change_window_width(direction)
    local nnp = require "plugins.no-neck-pain"

    local sidenotes_visible = nnp.are_sidenotes_visible()

    if direction == "up" then
        if sidenotes_visible then
            nnp.increase_window_width()
        else
            vim.cmd "vertical resize +5"
        end
    elseif direction == "down" then
        if sidenotes_visible then
            nnp.decrease_window_width()
        else
            vim.cmd "vertical resize -5"
        end
    else
        vim.api.nvim_err_writeln "Unexpected direction"
    end
end

function m.change_window_height(direction)
    if direction == "up" then
        vim.cmd "resize +5"
    elseif direction == "down" then
        vim.cmd "resize -5"
    else
        vim.api.nvim_err_writeln "Unexpected direction"
    end
end

function m.justify_layout()
    local nnp = require "plugins.no-neck-pain"

    local sidenotes_visible = nnp.are_sidenotes_visible()

    if sidenotes_visible then
        nnp.set_default_window_width()
    else
        vim.cmd "wincmd ="
    end
end

function m.reset_layout()
    local nnp = require "plugins.no-neck-pain"
    m.justify_layout()
    nnp.reload()
end

function m.get_tab_windows(options)
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

function m.get_normal_tab_windows(options)
    local opts

    if options and options.incl_sidenotes ~= nil then
        opts = { skip_sidenotes = not options.incl_sidenotes }
    else
        opts = { skip_sidenotes = true }
    end

    local windows = m.get_tab_windows()

    if not windows then return nil end

    local nnp = require "plugins.no-neck-pain"

    local result = {}

    local sidenotes = nnp.get_sidenotes()

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

return M
