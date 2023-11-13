local M = {}
local m = {}

function M.setup()
    local plugin = require "noice"

    plugin.setup {
        cmdline = {
            format = {
                search_down = { view = "cmdline" },
                search_up = { view = "cmdline" },
            },
        },
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        presets = {
            cmdline_output_to_split = true,
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
            cmdline_output = {
                enter = true,
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
            popupmenu = {
                relative = "editor",
                position = {
                    row = "42%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 15,
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = {
                        Normal = "Normal",
                        FloatBorder = "DiagnosticInfo",
                    },
                },
            },
        },
    }
end

function M.keymaps()
    K.map { "<C-i>", "LSP: Doc", require("noice.lsp").hover, mode = { "n", "v", "i" } }
end

function M.scroll_lsp_doc(direction)
    local plugin = require "noice.lsp"

    if direction == "up" then
        return plugin.scroll(-4)
    elseif direction == "down" then
        return plugin.scroll(4)
    else
        vim.api.nvim_err_writeln("Unexpected direction: " .. direction)
        return false
    end
end

function M.ensure_hidden()
    if m.is_cmdline_active() then
        m.exit_cmdline()
        return true
    end

    local current_win = vim.api.nvim_get_current_win()
    local hover_win = m.get_lsp_hover_win()

    if hover_win ~= nil and hover_win ~= current_win then
        local cursor = require "editor.cursor"

        local cleanup = cursor.shake()

        if not cleanup then
            vim.api.nvim_err_writeln "Failed to shake cursor"
            return true
        end

        vim.defer_fn(cleanup, 10)

        return true
    elseif m.is_win_active() then
        local windows = require "editor.windows"

        if windows.is_window_floating(current_win) then
            m.close_split()
            return true
        else
            local nnp = require "plugins.no-neck-pain"

            if nnp.are_sidenotes_visible() then
                nnp.disable()
                vim.api.nvim_set_current_win(current_win)
                m.close_split()
                nnp.enable()
            else
                m.close_split()
            end

            return true
        end
    else
        return false
    end
end

-- Private

function m.is_win_active()
    return vim.bo.filetype == "noice"
end

function m.is_cmdline_active()
    local mode = vim.fn.mode()
    return mode == "c"
end

function m.get_lsp_hover_win()
    local lsp = require "noice.lsp"
    local docs = require "noice.lsp.docs"

    local hover = docs.get(lsp.kinds.hover)

    if hover == nil then
        return nil
    end

    return hover.win(hover)
end

function m.close_split()
    vim.cmd.close()
end

function m.exit_cmdline()
    local keys = require "editor.keys"
    keys.send("<Esc>", { mode = "n" })
end

return M
