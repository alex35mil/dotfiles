NVWindows = {
    default_width = 120,
    maximized_width = 1,
    window_picker_keys = "UHKMETJWNSABCDFGILOPQRVXYZ1234567890",
}

local fn = {}

-- TODO: Revisit windows keymaps

function NVWindows.keymaps()
    K.map({ "<D-n>", "Create new buffer in the current window", "<Cmd>enew<CR>", mode = { "n", "v", "i" } })
    -- K.map({ "<Leader>nh", "Create new buffer in a horizontal split", "<Cmd>new<CR>", mode = "n" })
    -- K.map({ "<Leader>nn", "Create new buffer in a vertical split", "<Cmd>vnew<CR>", mode = "n" })

    K.map({ "<S-Left>", "Move to window on the left", "<Cmd>wincmd h<CR>", mode = { "n", "v", "t" } })
    K.map({ "<S-Down>", "Move to window below", "<Cmd>wincmd j<CR>", mode = { "n", "v", "t" } })
    K.map({ "<S-Up>", "Move to window above", "<Cmd>wincmd k<CR>", mode = { "n", "v", "t" } })
    K.map({ "<S-Right>", "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "v", "t" } })

    -- K.map({
    --     "<M-S-Left>",
    --     "Move window to the left",
    --     function()
    --         fn.reposition_windows({ action = "move_left" })
    --     end,
    --     mode = "n",
    -- })
    -- K.map({
    --     "<M-S-Right>",
    --     "Move window to the right",
    --     function()
    --         fn.reposition_windows({ action = "move_right" })
    --     end,
    --     mode = "n",
    -- })
    -- K.map({
    --     "<M-S-Up>",
    --     "Move window up",
    --     function()
    --         fn.reposition_windows({ action = "move_up" })
    --     end,
    --     mode = "n",
    -- })
    -- K.map({
    --     "<M-S-Down>",
    --     "Move window down",
    --     function()
    --         fn.reposition_windows({ action = "move_down" })
    --     end,
    --     mode = "n",
    -- })
    --
    -- K.map({
    --     "<Leader>ws",
    --     "Swap windows",
    --     function()
    --         fn.reposition_windows({ action = "swap" })
    --     end,
    --     mode = "n",
    -- })
    --
    -- K.map({
    --     "<C-S-Up>",
    --     "Increase window width",
    --     function()
    --         fn.change_window_width("up")
    --     end,
    --     mode = "n",
    -- })
    -- K.map({
    --     "<C-S-Down>",
    --     "Decrease window width",
    --     function()
    --         fn.change_window_width("down")
    --     end,
    --     mode = "n",
    -- })
    -- K.map({
    --     "<D-C-S-Up>",
    --     "Increase window height",
    --     function()
    --         fn.change_window_height("up")
    --     end,
    --     mode = "n",
    -- })
    -- K.map({
    --     "<D-C-S-Down>",
    --     "Decrease window height",
    --     function()
    --         fn.change_window_height("down")
    --     end,
    --     mode = "n",
    -- })

    -- K.map({ "<D-E>", "Equalize layout", fn.equalize_layout, mode = "n" })
    -- K.map({ "<D-X>", "Reset layout", fn.reset_layout, mode = "n" })
end

function NVWindows.is_window_floating(winid)
    local win = vim.api.nvim_win_get_config(winid)
    return win.relative ~= ""
end

function NVWindows.get_floating_tab_windows()
    local windows = fn.get_tab_windows()

    if not windows then
        return nil
    end

    local result = {}

    for _, winnr in ipairs(windows) do
        if NVWindows.is_window_floating(winnr) then
            table.insert(result, winnr)
        end
    end

    return result
end

function NVWindows.get_tab_windows_with_listed_buffers(options)
    local opts = vim.tbl_extend("keep", options, { incl_help = false })

    local windows = fn.get_normal_tab_windows()

    if not windows then
        return nil
    end

    local result = {}

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local incl_if_help = opts.incl_help and NVHelp.is_help(buf)

        if NVBuffers.is_buf_listed(buf) or incl_if_help then
            table.insert(result, win)
        end
    end

    return result
end

function fn.reposition_windows(opts)
    local action = opts.action

    local windows = fn.get_normal_tab_windows()

    if #windows == 2 and action == "swap" then
        NVNoNeckPain.update_layout_with(function()
            vim.cmd("wincmd r")
        end)
    elseif #windows > 1 then
        -- FIXME: Handle winshift
        local winshift = require("plugins.winshift")

        if action == "swap" then
            winshift.swap()
        elseif action == "move_left" then
            NVNoNeckPain.update_layout_with(winshift.move_left)
        elseif action == "move_right" then
            NVNoNeckPain.update_layout_with(winshift.move_right)
        elseif action == "move_up" then
            NVNoNeckPain.update_layout_with(winshift.move_up)
        elseif action == "move_down" then
            NVNoNeckPain.update_layout_with(winshift.move_down)
        else
            vim.api.nvim_err_writeln("Unexpected windows action")
        end
    else
        print("No windows to rotate")
        return
    end
end

function fn.change_window_width(direction)
    local sidepads_visible = NVNoNeckPain.are_sidepads_visible()

    if direction == "up" then
        if sidepads_visible then
            NVNoNeckPain.increase_window_width()
        else
            vim.cmd("vertical resize +5")
        end
    elseif direction == "down" then
        if sidepads_visible then
            NVNoNeckPain.decrease_window_width()
        else
            vim.cmd("vertical resize -5")
        end
    else
        vim.api.nvim_err_writeln("Unexpected direction")
    end
end

function fn.change_window_height(direction)
    if direction == "up" then
        vim.cmd("resize +5")
    elseif direction == "down" then
        vim.cmd("resize -5")
    else
        vim.api.nvim_err_writeln("Unexpected direction")
    end
end

function fn.equalize_layout()
    local sidepads_visible = NVNoNeckPain.are_sidepads_visible()

    if sidepads_visible then
        NVNoNeckPain.set_default_window_width()
        vim.cmd("vert wincmd =")
    else
        vim.cmd("wincmd =")
    end
end

function fn.reset_layout()
    fn.equalize_layout()
    NVNoNeckPain.reload()
end

function fn.get_tab_windows()
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

function fn.get_normal_tab_windows()
    local windows = fn.get_tab_windows()

    if not windows then
        return nil
    end

    local result = {}

    local sidepads = NVNoNeckPain.get_sidepads()

    for _, winid in ipairs(windows) do
        if not NVWindows.is_window_floating(winid) then
            if sidepads ~= nil then
                if winid ~= sidepads.left and winid ~= sidepads.right then
                    table.insert(result, winid)
                end
            else
                table.insert(result, winid)
            end
        end
    end

    return result
end
