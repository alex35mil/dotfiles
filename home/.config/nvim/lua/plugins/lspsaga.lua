local M = {}

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
                normal_bg = color.popover_bg,
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
            edit = "<CR>",
            vsplit = "v",
            split = "h",
            tabe = "t",
            quit = { "<Esc>", "<D-w>" },
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

return M
