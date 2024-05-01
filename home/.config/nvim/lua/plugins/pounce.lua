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
    -- <D-h> remapped via Karabiner
    K.map { "<C-M-h>", "Start pounce motion", "<Cmd>Pounce<CR>", mode = { "n", "v" } }
    K.map { "<C-M-h>", "Start pounce motion", "<Esc><Cmd>Pounce<CR>", mode = "i" }
end

return M
