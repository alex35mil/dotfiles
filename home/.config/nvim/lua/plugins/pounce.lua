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
    K.map { "<M-h>", "Start pounce motion", "<Cmd>Pounce<CR>", mode = { "n", "v" } } -- It's <D-h> remapped via Karabiner
end

return M
