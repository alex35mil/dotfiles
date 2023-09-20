local M = {}

function M.setup()
    local plugin = require "zen-mode"

    plugin.setup {
        window = {
            backdrop = 1,
            width = 118,
        },
    }
end

return M
