local M = {}

function M.setup()
    local plugin = require "pounce"

    plugin.setup {
        accept_keys = "HTNUEOSALDIBXGPKMFYCWJRQVZ",
        accept_best_key = "<CR>",
        multi_window = true,
    }
end

return M