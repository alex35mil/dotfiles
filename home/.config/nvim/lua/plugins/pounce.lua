local M = {}

function M.setup()
    local plugin = require "pounce"

    plugin.setup {
        accept_keys = "HTNUEOSALDIBXGPKMFYCWJRQVZ",
        accept_best_key = "<CR>",
        multi_window = true,
    }
end

function M.keymaps()
    K.map { "H", "Start pounce motion", "<Cmd>Pounce<CR>", mode = { "n", "v" } }
end

return M
