local plugin = require "lsp_lines"

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({ virtual_text = false })

plugin.setup {}
