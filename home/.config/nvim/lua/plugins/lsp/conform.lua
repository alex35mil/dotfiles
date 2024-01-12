local M = {}
local m = {}

function M.setup()
    local plugin = require "conform"

    local prettier = { { "prettierd", "prettier" } }

    plugin.setup({
        formatters_by_ft = {
            javascript = prettier,
            javascriptreact = prettier,
            typescript = prettier,
            typescriptreact = prettier,
            json = nil, -- handled by jsonls
            yaml = { "yamlfmt" },
        },
    })
end

function M.keymaps()
    K.map { "<M-f>", "Format current buffer", m.format, mode = { "n", "v" } }
end

-- Private

function m.format()
    local conform = require "conform"

    local formatted = conform.format()

    if formatted then
        return
    else
        vim.lsp.buf.format()
    end
end

return M
