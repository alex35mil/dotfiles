local M = {}


function M.setup()
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
end

return M
