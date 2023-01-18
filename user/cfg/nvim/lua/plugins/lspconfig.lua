local mason = require "mason"
local mason_cfg = require "mason-lspconfig"
local lsp_cfg = require "lspconfig"
local neodev = require "neodev"

local signs = require "utils/lsp".signs

vim.diagnostic.config {
    signs = true,
    severity_sort = true,
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

mason.setup {}

mason_cfg.setup {
    ensure_installed = {
        "sumneko_lua",
        -- "ocamllsp", -- FIXME: Ocaml LSP is broken
        "rescriptls",
        -- NOTE: rust is handled by the `rust-tools`
    },
}

-- lua
neodev.setup {}

lsp_cfg.sumneko_lua.setup {
    settings = {
        Lua = {
            format = {
                enable = true,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}

-- rust
local rust_tools = require("rust-tools")

rust_tools.setup {
    server = {
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
}

-- ocaml
lsp_cfg.ocamllsp.setup {}

-- rescript
lsp_cfg.rescriptls.setup {}
