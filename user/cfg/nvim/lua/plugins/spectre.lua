local plugin = require "spectre"

plugin.setup {
    default = {
        find = {
            cmd = "rg",
            options = {},
        },
        replace = {
            cmd = "sed",
            options = {},
        },
    },
}
