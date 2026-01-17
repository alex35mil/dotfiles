NVWindows = {
    maximized_width = 1, -- 100%
    window_picker_keys = "UHKMETJWNSABCDFGILOPQRVXYZ1234567890",
}

local fn = {}

function NVWindows.keymaps()
    K.map({ "<D-n>", "Create new buffer in the current window", "<Cmd>enew<CR>", mode = { "n", "v", "i" } })
    K.map({ "<Leader>nh", "Create new buffer in a horizontal split", "<Cmd>new<CR>", mode = "n" })
    K.map({ "<Leader>nn", "Create new buffer in a vertical split", "<Cmd>vnew<CR>", mode = "n" })

    K.map({ "<S-Left>", "Move to window on the left", "<Cmd>wincmd h<CR>", mode = { "n", "v", "i", "t" } })
    K.map({ "<S-Down>", "Move to window below", "<Cmd>wincmd j<CR>", mode = { "n", "v", "i", "t" } })
    K.map({ "<S-Up>", "Move to window above", "<Cmd>wincmd k<CR>", mode = { "n", "v", "i", "t" } })
    K.map({ "<S-Right>", "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "v", "i", "t" } })

    K.map({
        "<M-S-Left>",
        "Move window to the left",
        function()
            fn.reposition_windows({ action = "move_left" })
        end,
        mode = { "n", "i", "v" },
    })
    K.map({
        "<M-S-Right>",
        "Move window to the right",
        function()
            fn.reposition_windows({ action = "move_right" })
        end,
        mode = { "n", "i", "v" },
    })
    K.map({
        "<M-S-Up>",
        "Move window up",
        function()
            fn.reposition_windows({ action = "move_up" })
        end,
        mode = { "n", "i", "v" },
    })
    K.map({
        "<M-S-Down>",
        "Move window down",
        function()
            fn.reposition_windows({ action = "move_down" })
        end,
        mode = { "n", "i", "v" },
    })

    K.map({
        "<M-s>",
        "Swap windows",
        function()
            fn.reposition_windows({ action = "swap" })
        end,
        mode = { "n", "i", "v" },
    })

    K.map({
        "<C-S-Up>",
        "Increase window width",
        function()
            fn.change_window_width("up")
        end,
        mode = { "n", "i", "v", "t" },
    })
    K.map({
        "<C-S-Down>",
        "Decrease window width",
        function()
            fn.change_window_width("down")
        end,
        mode = { "n", "i", "v", "t" },
    })
    K.map({
        "<C-D-S-Up>",
        "Increase window height",
        function()
            fn.change_window_height("up")
        end,
        mode = { "n", "i", "v" },
    })
    K.map({
        "<C-D-S-Down>",
        "Decrease window height",
        function()
            fn.change_window_height("down")
        end,
        mode = { "n", "i", "v" },
    })

    K.map({ "<A-e>", "Equalize layout", fn.equalize_layout, mode = { "n", "i", "v" } })
end

---@param winid WinID
function NVWindows.is_window_floating(winid)
    local win = vim.api.nvim_win_get_config(winid)
    return win.relative ~= ""
end

---@return WinID[]?
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

---@param options {incl_help: boolean}?
---@return WinID[]?
function NVWindows.get_tab_windows_with_listed_buffers(options)
    local opts = vim.tbl_extend("keep", options or {}, { incl_help = false })

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

---@param opts {action: "swap" | "move_left" | "move_right" | "move_up" | "move_down"}
function fn.reposition_windows(opts)
    local action = opts.action

    local windows = fn.get_normal_tab_windows()

    if #windows == 2 and action == "swap" then
        vim.cmd("wincmd r")
    elseif #windows > 1 then
        if action == "swap" then
            NVWinshift.swap()
        elseif action == "move_left" then
            NVWinshift.move_left()
        elseif action == "move_right" then
            NVWinshift.move_right()
        elseif action == "move_up" then
            NVWinshift.move_up()
        elseif action == "move_down" then
            NVWinshift.move_down()
        else
            log.error("Unexpected windows action")
        end
    else
        log.info("No windows to rotate")
        return
    end
end

---@param direction "up"|"down"
function fn.change_window_width(direction)
    if direction == "up" then
        NVLayout.increase_width()
    elseif direction == "down" then
        NVLayout.decrease_width()
    else
        log.error("Window Width Change: Unexpected direction")
    end
end

---@param direction "up"|"down"
function fn.change_window_height(direction)
    if direction == "up" then
        vim.cmd("resize +3")
    elseif direction == "down" then
        vim.cmd("resize -3")
    else
        log.error("Window Height Change: Unexpected direction")
    end
end

function fn.equalize_layout()
    NVLayout.reset_width()
    vim.cmd("wincmd =")
end

---@return WinID[]?
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

---@return WinID[]?
function fn.get_normal_tab_windows()
    local windows = fn.get_tab_windows()

    if not windows then
        return nil
    end

    local result = {}

    for _, winid in ipairs(windows) do
        if not NVWindows.is_window_floating(winid) then
            if not NVLayout.is_sidepad_win(winid) then
                table.insert(result, winid)
            end
        end
    end

    return result
end
