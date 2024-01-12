local M = {}
local m = {}

function M.setup()
    local plugin = require "lsp_lines"

    -- Disabling virtual lines by deafult as they are too annoying when editing
    vim.diagnostic.config({ virtual_lines = false })

    plugin.setup()
end

function M.keymaps()
    K.map { "<C-l>", "LSP: Toggle diagnostic lines", m.toggle, mode = { "n", "v" } }
end

-- Private

function m.toggle()
    local plugin = require "lsp_lines"
    local visible = plugin.toggle()
    vim.diagnostic.config({ virtual_text = not visible })
end

return M
