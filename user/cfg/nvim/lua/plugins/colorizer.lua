local M = {}

function M.setup()
    local plugin = require "colorizer"

    plugin.setup {
        "css",
    }
end

return M
