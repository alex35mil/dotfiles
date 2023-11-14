local M = {}
local m = {}

function M.setup()
    local plugin = require "persistence"

    plugin.setup {
        pre_save = function()
            local lazy = require "plugins.lazy"
            local nnp = require "plugins.no-neck-pain"
            local noice = require "plugins.noice"
            local zenmode = require "plugins.zen-mode"
            local spectre = require "plugins.spectre"
            local filetree = require "plugins.neo-tree"
            local toggleterm = require "plugins.toggleterm"
            local mason = require "plugins.lsp.mason"
            local lazygit = require "plugins.git.lazygit"
            local diffview = require "plugins.git.diffview"

            local mode = vim.fn.mode()

            if mode == "i" or mode == "v" then
                local keys = require "editor.keys"
                keys.send("<Esc>", { mode = "x" })
            end

            lazy.ensure_hidden()
            noice.ensure_hidden()
            zenmode.ensure_deacitvated()
            spectre.ensure_any_closed()
            filetree.ensure_any_hidden()
            toggleterm.ensure_any_hidden()
            mason.ensure_hidden()
            lazygit.ensure_hidden()
            diffview.ensure_all_hidden()
            nnp.disable()

            -- For some reason, it breaks persistence so that the session is not saved
            -- vim.cmd "wa"
        end,
        save_empty = true,
    }
end

function M.keymaps()
    K.map { "<M-r>", "Restore last session", m.restore_session, mode = "n" }
end

-- Private

function m.restore_session()
    local persistence = require "persistence"
    local nnp = require "plugins.no-neck-pain"

    persistence.load { last = true }
    nnp.reload()
end

return M
