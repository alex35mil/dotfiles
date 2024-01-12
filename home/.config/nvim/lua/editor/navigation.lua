local M = {}
local m = {}

function M.keymaps()
    K.map { "<D-Up>", "Move cursor half-screen up", "<C-u>", mode = { "n", "v" } }
    K.map { "<D-Down>", "Move cursor half-screen down", "<C-d>", mode = { "n", "v" } }
    K.map { "<C-t>", "Scroll up", function() m.scroll_vertical("up") end, mode = { "n", "v", "i" } }
    K.map { "<C-h>", "Scroll down", function() m.scroll_vertical("down") end, mode = { "n", "v", "i" } }
    K.map { "<C-d>", "Scroll left", function() m.scroll_horizontal("left") end, mode = { "n", "v", "i" } }
    K.map { "<C-n>", "Scroll right", function() m.scroll_horizontal("right") end, mode = { "n", "v", "i" } }

    K.map { "<D-Left>", "History: back", "<C-o>", mode = "n" }
    K.map { "<D-Right>", "History: forward", "<C-i>", mode = "n" }
end

-- Private

function m.scroll_horizontal(direction)
    if direction == "left" then
        vim.cmd "normal! 5zh"
    elseif direction == "right" then
        vim.cmd "normal! 5zl"
    else
        vim.api.nvim_err_writeln "Unexpected scroll direction"
    end
end

function m.scroll_vertical(direction)
    local windows = require "editor.windows"
    local keys = require "editor.keys"
    local noice = require "plugins.noice"

    if noice.scroll_lsp_doc(direction) then
        return
    elseif windows.is_window_floating(vim.api.nvim_get_current_win()) then
        local keymap

        if direction == "up" then
            keymap = "<C-u>"
        elseif direction == "down" then
            keymap = "<C-d>"
        else
            vim.api.nvim_err_writeln "Unexpected scroll direction"
            return
        end

        keys.send(keymap, { mode = "n" })
    else
        local lines = 5

        local keymap

        if direction == "up" then
            keymap = "<C-y>"
        elseif direction == "down" then
            keymap = "<C-e>"
        else
            vim.api.nvim_err_writeln "Unexpected scroll direction"
            return
        end

        local mode = vim.fn.mode()

        local is_i_mode = mode == "i"

        if is_i_mode then
            keys.send("<Esc>", { mode = "n" })
        end

        keys.send(tostring(lines) .. keymap, { mode = "n" })

        if is_i_mode then
            keys.send("a", { mode = "n" })
        end
    end
end

return M
