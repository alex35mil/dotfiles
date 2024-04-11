local M = {}

function M.setup()
    local plugin = require "fugit2"
    plugin.setup()
end

function M.keymaps()
    K.mapseq { "<D-g>f", "Git: Show fugit2", "<Cmd>Fugit2<CR>", mode = "n" }
end

-- TODO: Adjust highlights
-- TODO: Handle closing with <D-w>

return M
