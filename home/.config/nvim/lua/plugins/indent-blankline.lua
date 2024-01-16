local M = {}

function M.setup()
    local plugin = require "ibl"

    plugin.setup {
        enabled = true,
        indent = {
            char = "│",
            highlight = "IblIndent",
        },
    }
end

return M
