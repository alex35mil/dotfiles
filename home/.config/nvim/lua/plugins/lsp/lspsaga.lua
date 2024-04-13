local M = {}
local m = {}

function M.setup()
    local plugin = require "lspsaga"
    local color = require "theme.palette"

    plugin.setup {
        ui = {
            theme = "round",
            border = "rounded",
            title = true,
            winblend = 0,
            expand = "",
            collapse = "",
            preview = "",
            code_action = "﬌",
            diagnostic = "", -- or 
            incoming = " ",
            outgoing = " ",
            lines = { "┗", "┣", "┃", "━", "┏" },
            colors = {
                normal_bg = color.bg,
                title_bg = color.cyan,
            },
            kind = nil,
        },
        symbol_in_winbar = {
            enable = false,
        },
        rename = {
            auto_save = true,
            in_select = false,
            keys = {
                quit = { "<Esc>", "<D-w>" },
                exec = "<CR>",
                select = "x",
            },
        },
        diagnostic = {
            show_code_action = true,
            show_source = true,
            jump_num_shortcut = true,
            keys = {
                exec_action = "o",
                quit = { "<Esc>", "<D-w>" },
                go_action = "g",
            },
        },
        finder = {
            keys = {
                edit = "<CR>",
                vsplit = "<S-Right>",
                split = "<S-Down>",
                tabe = nil,
                quit = { "<Esc>", "<D-w>" },
            },
        },
        outline = {
            layout = "float",
        },
        code_action = {
            num_shortcut = true,
            keys = {
                quit = { "<Esc>", "<D-w>" },
                exec = "<CR>",
            },
        },
        lightbulb = {
            enable = false,
        },
        beacon = {
            enable = true,
            frequency = 7,
        },
        request_timeout = 5000,
    }
end

function M.keymaps()
    K.map { "<D-H>", "LSP: Jump to definition", "<Cmd>Lspsaga goto_definition<CR>", mode = "n" }
    K.map { "<D-G>", "LSP: Jump to type definition", "<Cmd>Lspsaga goto_type_definition<CR>", mode = "n" }
    K.map { "<D-r>", "LSP: Rename", "<Cmd>Lspsaga rename<CR>", mode = "n" }
    K.map { "<C-a>", "LSP: Code actions", "<Cmd>Lspsaga code_action<CR>", mode = "n" }
    K.map { "<C-f>", "LSP: Finder", "<Cmd>Lspsaga finder<CR>", mode = "n" }

    K.map { "<D-S-Down>", "LSP: Diagnostic next error", m.jump_to_next_error, mode = "n" }
    K.map { "<D-S-Up>", "LSP: Diagnostic previous error", m.jump_to_prev_error, mode = "n" }
    K.map { "<D-C-S-Down>", "LSP: Diagnostic next warning", m.jump_to_next_warning, mode = "n" }
    K.map { "<D-C-S-Up>", "LSP: Diagnostic previous warning", m.jump_to_prev_warning, mode = "n" }
end

-- Private

local severity = vim.diagnostic.severity

function m.jump_to_prev_warning()
    local diagnostic = require "lspsaga.diagnostic"
    diagnostic:goto_prev({ severity = severity.WARN })
end

function m.jump_to_next_warning()
    local diagnostic = require "lspsaga.diagnostic"
    diagnostic:goto_next({ severity = severity.WARN })
end

function m.jump_to_prev_error()
    local diagnostic = require "lspsaga.diagnostic"
    diagnostic:goto_prev({ severity = severity.ERROR })
end

function m.jump_to_next_error()
    local diagnostic = require "lspsaga.diagnostic"
    diagnostic:goto_next({ severity = severity.ERROR })
end

return M
