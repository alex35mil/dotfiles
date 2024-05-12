local M = {}
local m = {}

function M.keymaps()
    K.mapseq { "<D-g>g", "Git: Show lazygit", "<Cmd>LazyGit<CR>", mode = "n" }
    K.map { "<D-Up>", "Lazygit: Scroll up main panel", "<C-\\><C-t>", mode = "t" }
    K.map { "<D-Down>", "Lazygit: Scroll down main panel", "<C-\\><C-h>", mode = "t" }
end

function M.ensure_hidden()
    if m.is_active() then
        m.close()
        return true
    else
        return false
    end
end

-- Private

function m.is_active()
    return vim.bo.filetype == "lazygit"
end

function m.close()
    local keys = require "editor.keys"
    keys.send("w", { mode = "t" })
end

return M
