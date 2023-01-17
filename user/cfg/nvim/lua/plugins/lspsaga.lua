local plugin = require "lspsaga"
local color = require "theme/palette"

plugin.setup {
    ui = {
        theme = "round",
        border = "solid",
        title = true,
        winblend = 0,
        expand = "",
        collapse = "",
        preview = "",
        code_action = "﬌",
        diagnostic = "", -- or 
        incoming = " ",
        outgoing = " ",
        colors = {
            normal_bg = color.popover_bg,
            title_bg = color.cyan,
        },
        kind = {},
    },
    symbol_in_winbar = {
        enable = false,
    },
    rename = {
        quit = "<Esc>",
        exec = "<CR>",
        mark = "x",
        confirm = "<CR>",
        in_select = false,
        whole_project = true,
    },
    diagnostic = {
        show_code_action = true,
        show_source = true,
        jump_num_shortcut = true,
        keys = {
            exec_action = "o",
            quit = "<Esc>",
            go_action = "g",
        },
    },
    finder = {
        edit = "<CR>",
        vsplit = "v",
        split = "h",
        tabe = "t",
        quit = { "<Esc>", "q" },
    },
    code_action = {
        num_shortcut = true,
        keys = {
            quit = { "<Esc>", "q" },
            exec = "<CR>",
        },
    },
    lightbulb = {
        enable = false, -- FIXME: Lightbulb is broken
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
    },
    request_timeout = 5000,
}
