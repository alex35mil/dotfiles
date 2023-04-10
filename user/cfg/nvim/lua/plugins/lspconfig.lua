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
    -- NOTE: rust is handled by the `rust-tools`
    ensure_installed = {
        "bashls",
        "cssls",
        "dockerls",
        "docker_compose_language_service",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        "nil_ls", -- nix
        -- "ocamllsp", -- FIXME: Ocaml LSP is broken
        "reason_ls",
        "rescriptls",
        "sqlls",
        "tailwindcss",
        "tsserver",
        "yamlls",
    },
}

-- lua
neodev.setup {}

lsp_cfg.lua_ls.setup {
    settings = {
        Lua = {
            format = {
                enable = true,
            },
            telemetry = {
                enable = false,
            },
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}

-- rust
local rust_tools = require "rust-tools"

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


-- rescript
lsp_cfg.rescriptls.setup {}

function ReScriptCreateInterfaceFile()
    local path = vim.api.nvim_buf_get_name(0)

    if vim.fn.filereadable(path .. "i") == 1 then
        print("Interface file already exists")
    else
        vim.lsp.buf_request(
            0,
            "textDocument/createInterface",
            { uri = "file://" .. path },
            function()
                print("Interface file created")
            end
        )
    end
end

vim.cmd("command ReScriptCreateInterfaceFile lua ReScriptCreateInterfaceFile()")

-- typescript
lsp_cfg.tsserver.setup {
    on_attach = function(client)
        -- Formatting is handled by null-ls prettier
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
}

-- yaml
lsp_cfg.yamlls.setup {
    settings = {
        yaml = {
            keyOrdering = false,
        },
    },
}

-- rest
lsp_cfg.bashls.setup {}
lsp_cfg.cssls.setup {}
lsp_cfg.dockerls.setup {}
lsp_cfg.docker_compose_language_service.setup {}
lsp_cfg.html.setup {}
lsp_cfg.jsonls.setup {}
lsp_cfg.marksman.setup {}
lsp_cfg.nil_ls.setup {}
lsp_cfg.ocamllsp.setup {}
lsp_cfg.reason_ls.setup {}
lsp_cfg.sqlls.setup {}
lsp_cfg.tailwindcss.setup {}
