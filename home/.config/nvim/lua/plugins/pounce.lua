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
    -- Remapped via Karabiner to <Ctrl-h> (same keymap as Wooshy)
    K.map { "<C-M-S-h>", "Start pounce motion", "<Cmd>Pounce<CR>", mode = { "n", "v" } }
    K.map { "<C-M-S-h>", "Start pounce motion", "<Esc><Cmd>Pounce<CR>", mode = "i" }
end

return M
