local M = {}
local m = {}

M.window_picker_keys = "UHKMETJWNSABCDFGILOPQRVXYZ1234567890"

function M.keymaps()
    K.map { "<D-n>", "Create new buffer in the current window", "<Cmd>enew<CR>", mode = { "n", "v", "i" } }
    K.mapseq { "<Leader>nh", "Create new buffer in a horizontal split", "<Cmd>new<CR>", mode = "n" }
    K.mapseq { "<Leader>nv", "Create new buffer in a vertical split", "<Cmd>vnew<CR>", mode = "n" }

    K.map { "<D-Left>", "Move to window on the left", "<Cmd>wincmd h<CR>", mode = { "n", "v", "t" } }
    K.map { "<D-Down>", "Move to window below", "<Cmd>wincmd j<CR>", mode = { "n", "v", "t" } }
    K.map { "<D-Up>", "Move to window above", "<Cmd>wincmd k<CR>", mode = { "n", "v", "t" } }
    K.map { "<D-Right>", "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "v", "t" } }

    K.map { "<D-m>", "Move windows", function() m.reposition_windows({ action = "move" }) end, mode = "n" }
    K.map { "<M-s>", "Swap windows", function() m.reposition_windows({ action = "swap" }) end, mode = "n" }

    K.map { "<C-Up>", "Increase window width", function() m.change_window_width("up") end, mode = "n" }
    K.map { "<C-Down>", "Decrease window width", function() m.change_window_width("down") end, mode = "n" }
    K.map { "<C-Esc>", "Restore windows width", m.restore_windows_layout, mode = "n" }
    K.map { "<D-Esc>", "Reset layout", m.reset_layout, mode = "n" }
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

    local windows = m.get_normal_tab_windows({ incl_sidenotes = false })
    local sidenotes_visible = nnp.are_sidenotes_visible()

    if #windows == 2 then
        if sidenotes_visible then nnp.disable() end
        vim.cmd "wincmd r"
        if sidenotes_visible then nnp.enable() end
    elseif #windows > 2 then
        local winshift = require "plugins.winshift"

        local action = opts.action

        if action == "move" then
            if sidenotes_visible then nnp.disable() end
            winshift.move()
            -- FIXME: With sidenotes visible, layout messes up.
            -- It makes sense to disable nnp while moving, and re-enable it afterwards,
            -- but winshift doesn't provide an api to do that:
            -- https://github.com/sindrets/winshift.nvim/issues/19
        elseif action == "swap" then
            winshift.swap()
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

function m.restore_windows_layout()
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
