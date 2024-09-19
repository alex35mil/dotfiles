local fn = {}

NVNoice = {
    "folke/noice.nvim",
    keys = {
        { "<D-i>", require("noice.lsp").hover, mode = { "n", "v", "i" }, desc = "LSP: Doc" },
    },
    opts = {
        cmdline = {
            format = {
                search_down = { view = "cmdline" },
                search_up = { view = "cmdline" },
            },
        },
        views = {
            cmdline = {
                position = {
                    row = 0,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 1,
                },
            },
            cmdline_popup = {
                position = {
                    row = "30%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
            cmdline_output = {
                enter = true,
            },
        },
    },
}

function NVNoice.scroll_lsp_doc(direction)
    local plugin = require("noice.lsp")

    if direction == "up" then
        return plugin.scroll(-4)
    elseif direction == "down" then
        return plugin.scroll(4)
    else
        vim.api.nvim_err_writeln("Unexpected direction: " .. direction)
        return false
    end
end

function NVNoice.ensure_hidden()
    if fn.is_cmdline_active() then
        fn.exit_cmdline()
        return true
    end

    local current_win = vim.api.nvim_get_current_win()
    local hover_win = fn.get_lsp_hover_win()

    if hover_win ~= nil and hover_win ~= current_win then
        local cleanup = NVCursor.shake()

        if not cleanup then
            vim.api.nvim_err_writeln("Failed to shake cursor")
            return true
        end

        vim.schedule(cleanup)

        return true
    elseif fn.is_win_active() then
        if NVWindows.is_window_floating(current_win) then
            fn.close_split()
            return true
        else
            if NVNoNeckPain.are_sidepads_visible() then
                NVNoNeckPain.update_layout_with(function()
                    vim.api.nvim_set_current_win(current_win)
                    fn.close_split()
                end, { check_sidepads_visibility = false })
            else
                fn.close_split()
            end

            return true
        end
    else
        return false
    end
end

function fn.is_win_active()
    return vim.bo.filetype == "noice"
end

function fn.is_cmdline_active()
    local mode = vim.fn.mode()
    return mode == "c"
end

function fn.get_lsp_hover_win()
    local lsp = require("noice.lsp")
    local docs = require("noice.lsp.docs")

    local hover = docs.get(lsp.kinds.hover)

    if hover == nil then
        return nil
    end

    return hover.win(hover)
end

function fn.close_split()
    vim.cmd.close()
end

function fn.exit_cmdline()
    NVKeys.send("<Esc>", { mode = "n" })
end

return { NVNoice }
