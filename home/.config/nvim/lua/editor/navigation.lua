NVNavigation = {}

local fn = {}

function NVNavigation.keymaps()
    K.map({
        NVKeymaps.scroll.up,
        "Scroll up",
        function()
            fn.scroll_vertical("up")
        end,
        mode = { "n", "v", "i" },
    })
    K.map({
        NVKeymaps.scroll.down,
        "Scroll down",
        function()
            fn.scroll_vertical("down")
        end,
        mode = { "n", "v", "i" },
    })

    K.map({ "<D-S-Up>", "Scroll a bit up", "<Cmd>normal 2<C-y><CR>", mode = { "n", "v", "i" } })
    K.map({ "<D-S-Down>", "Scroll a bit down", "<Cmd>normal 2<C-e><CR>", mode = { "n", "v", "i" } })

    K.map({
        "<D-S-Left>",
        "Scroll left",
        function()
            fn.scroll_horizontal("left")
        end,
        mode = { "n", "v", "i" },
    })
    K.map({
        "<D-S-Right>",
        "Scroll right",
        function()
            fn.scroll_horizontal("right")
        end,
        mode = { "n", "v", "i" },
    })

    K.map({ "<C-S-Left>", "History: back", "<C-o>", mode = "n" })
    K.map({ "<C-S-Right>", "History: forward", "<C-i>", mode = "n" })
end

---@param direction "left" | "right"
function fn.scroll_horizontal(direction)
    if direction == "left" then
        vim.cmd("normal! 7zh")
    elseif direction == "right" then
        vim.cmd("normal! 7zl")
    else
        log.error("Unexpected scroll direction")
    end
end

---@param direction "up" | "down"
function fn.scroll_vertical(direction)
    NVLspPopup.hide_unless_active()

    local command

    if NVWindows.is_window_floating(vim.api.nvim_get_current_win()) then
        if direction == "up" then
            command = "<C-u>"
        elseif direction == "down" then
            command = "<C-d>"
        else
            log.error("Unexpected scroll direction")
            return
        end
    else
        -- if we already at the top, place cursor on the first line
        if direction == "up" and vim.fn.line("w0") == 1 then
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
            return
        end

        -- if we already at the bottom, place cursor on the last line
        if direction == "down" and vim.fn.line("w$") == vim.fn.line("$") then
            local line_count = vim.api.nvim_buf_line_count(0)
            vim.api.nvim_win_set_cursor(0, { line_count, 0 })
            return
        end

        -- otherwise, scroll
        local lines = 15

        if direction == "up" then
            command = "<C-y>"
        elseif direction == "down" then
            command = "<C-e>"
        else
            log.error("Unexpected scroll direction")
            return
        end

        command = tostring(lines) .. command
    end

    local is_i_mode = vim.fn.mode() == "i"

    if is_i_mode then
        NVKeys.send("<Esc>", { mode = "n" })
    end

    NVKeys.send(command, { mode = "n" })

    if is_i_mode then
        NVKeys.send("a", { mode = "n" })
    end
end
