local plugin = require "lualine"
local mode = require "lualine.utils.mode"
local color = require "theme/palette"

local theme = {
    normal = {
        a = { fg = color.bg, bg = color.cyan, gui = "bold" },
        b = { fg = color.text, bg = color.darker_gray },
        c = { fg = color.text, bg = color.bg },
    },
    command = { a = { fg = color.bg, bg = color.yellow, gui = "bold" } },
    insert = { a = { fg = color.bg, bg = color.green, gui = "bold" } },
    visual = { a = { fg = color.bg, bg = color.purple, gui = "bold" } },
    terminal = { a = { fg = color.bg, bg = color.cyan, gui = "bold" } },
    replace = { a = { fg = color.bg, bg = color.red, gui = "bold" } },
    inactive = {
        a = { fg = color.strong_faded_text, bg = color.bg, gui = "bold" },
        b = { fg = color.strong_faded_text, bg = color.bg },
        c = { fg = color.strong_faded_text, bg = color.bg },
    },
}

plugin.setup {
    options = {
        icons_enabled = true,
        theme = theme,
        component_separators = "",
        section_separators = {
            left = "",
            -- left = "",
            right = "",
        },
        disabled_filetypes = {
            "NvimTree",
            "TelescopePrompt",
            "packer",
            "toggleterm",
        },
        always_divide_middle = true,
        globalstatus = true,
    },
    sections = {
        lualine_a = {
            {
                function()
                    local m = mode.get_mode()
                    if m == "NORMAL" then return "N"
                    elseif m == "VISUAL" then return "V"
                    elseif m == "SELECT" then return "S"
                    elseif m == "INSERT" then return "I"
                    elseif m == "REPLACE" then return "R"
                    elseif m == "COMMAND" then return "C"
                    elseif m == "EX" then return "X"
                    elseif m == "TERMINAL" then return "T"
                    else return m
                    end
                end,
            },
        },
        lualine_b = {
            "diff",
            "diagnostics",
            {
                "filename",
                path = 0,
                color = { fg = color.text, bg = color.lighter_gray },
            },
            {
                "branch",
                color = { fg = color.text, bg = color.darker_gray },
            },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
            "searchcount",
            "encoding",
            {
                "filetype",
                colored = false,
            },
            {
                "progress",
                separator = { left = "" },
                color = { fg = color.text, bg = color.lighter_gray },
            },
        },
        lualine_z = {
            {
                "location",
                padding = { left = 0, right = 1 },
                color = { fg = color.text, bg = color.lighter_gray },
            },
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = { "filename" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { "location" },
        lualine_z = {},
    },
    tabline = {},
}
