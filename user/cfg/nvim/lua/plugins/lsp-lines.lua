local plugin = require "lsp_lines"

-- Disabling virtual lines by deafult as they are too annoying when editing
vim.diagnostic.config({ virtual_lines = false })

plugin.setup {}
