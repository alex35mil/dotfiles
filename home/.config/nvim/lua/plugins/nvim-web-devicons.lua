NVWebDevicons = {
    "nvim-tree/nvim-web-devicons",
    opts = {
        override = {
            term = {
                icon = "",
                name = "Terminal",
            },
            picker = {
                icon = "󱐁",
                name = "Picker",
            },
            finder = {
                icon = "󰀶",
                name = "Finder",
            },
            preview = {
                icon = "",
                name = "Preview",
            },
            plugins = {
                icon = "",
                name = "Plugins",
            },
            tools = {
                icon = "󱁤",
                name = "Tools",
            },
        },
    },
    config = function(_, opts)
        local devicons = require("nvim-web-devicons")
        devicons.setup(opts)
        devicons.set_icon_by_filetype({
            snacks_terminal = "term",
            snacks_picker_input = "picker",
            snacks_picker_list = "finder",
            snacks_picker_preview = "preview",
            lazy = "plugins",
            mason = "tools",
            DiffviewFiles = "diff",
        })
    end,
}

return { NVWebDevicons }
