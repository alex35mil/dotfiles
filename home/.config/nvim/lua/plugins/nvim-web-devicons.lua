NVWebDevicons = {
    "nvim-tree/nvim-web-devicons",
    opts = {
        override = {
            rs = {
                icon = "",
                color = "#a52b00",
                name = "Rust",
            },
            term = {
                icon = "",
                color = "#00ff00",
                name = "Terminal",
            },
        },
    },
    config = function(_, opts)
        local devicons = require("nvim-web-devicons")
        devicons.setup(opts)
        devicons.set_icon_by_filetype({ snacks_terminal = "term" })
    end,
}

return { NVWebDevicons }
