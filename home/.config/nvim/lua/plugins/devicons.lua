local M = {}

function M.setup()
    local plugin = require "nvim-web-devicons"

    plugin.setup {
        color_icons = false,
        default = true,
        default_icon = {
            icon = "",
            name = "Default",
        },
        override = {
            rs = {
                icon = "",
                color = "#e43717",
                name = "Rs",
            },
        },
    }
end

return M
