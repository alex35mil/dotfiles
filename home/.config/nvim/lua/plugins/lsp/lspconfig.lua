local M = {}

M.signs = {
    Error = "ﮊ",
    Warn  = "󱅧",
    Hint  = "﮸",
    Info  = "",
}

function M.setup()
    local lsp = vim.lsp

    local config = require "lspconfig"
    local mason = require "plugins.lsp.mason"

    local lua = require "plugins.lsp.servers.lua"
    local rust = require "plugins.lsp.servers.rust"
    local ocaml = require "plugins.lsp.servers.ocaml"
    local rescript = require "plugins.lsp.servers.rescript"
    local typescript = require "plugins.lsp.servers.typescript"
    local json = require "plugins.lsp.servers.json"
    local yaml = require "plugins.lsp.servers.yaml"

    vim.diagnostic.config {
        signs = true,
        severity_sort = true,
    }

    for type, icon in pairs(M.signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "rounded" })

    mason.setup()

    lua.setup(config)
    rust.setup()
    ocaml.setup(config)
    rescript.setup(config)
    typescript.setup(config)
    json.setup(config)
    yaml.setup(config)

    config.bashls.setup {}
    config.cssls.setup {}
    config.dockerls.setup {}
    config.docker_compose_language_service.setup {}
    config.html.setup {}
    config.marksman.setup {}
    config.nil_ls.setup {}
    config.ocamllsp.setup {}
    config.reason_ls.setup {}
    config.sourcekit.setup {}
    config.sqlls.setup {}
    config.tailwindcss.setup {}
end

return M
