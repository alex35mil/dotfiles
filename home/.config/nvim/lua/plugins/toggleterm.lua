local M = {}

function M.setup()
    local plugin = require "toggleterm"

    plugin.setup {
        shade_terminals = false,
    }
end

return M
