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
            nix = { "alejandra" },
        },
    })
end

function M.keymaps()
    K.map { "<M-f>", "Format current buffer", M.format, mode = { "n", "v", "i" } }
end

function M.format()
    m.trim()

    local formatted = require("conform").format()

    if not formatted then
        m.try_lsp_format()
    end
end

-- Private

function m.trim()
    local trailspace = require "mini.trailspace"

    trailspace.trim()
    trailspace.trim_last_lines()
    vim.api.nvim_buf_set_lines(0, 0, vim.fn.nextnonblank(1) - 1, true, {})
end

function m.try_lsp_format()
    local filetype = vim.bo.filetype

    local clients = vim.lsp.get_clients()

    local client

    for _, c in ipairs(clients) do
        if c.config ~= nil and c.config.filetypes ~= nil then
            for _, ft in ipairs(c.config.filetypes) do
                if ft == filetype and c.server_capabilities.documentFormattingProvider then
                    client = c
                    break
                end
            end
        end

        if client then
            break
        end
    end

    if client then
        vim.lsp.buf.format()
    end
end

return M
