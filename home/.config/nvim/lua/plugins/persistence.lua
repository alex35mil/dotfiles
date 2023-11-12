local M = {}
local m = {}

function M.setup()
    local plugin = require "persistence"
    local nnp = require "plugins.no-neck-pain"

    plugin.setup {
        pre_save = nnp.ensure_sidenotes_hidden,
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
