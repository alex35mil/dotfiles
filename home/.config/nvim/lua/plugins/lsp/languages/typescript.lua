local lsp_settings = {
    preferences = {
        quoteStyle = "double",
    },
    format = {
        enable = true,
        semicolons = "remove",
    },
}

local prettier = { "prettierd", "prettier", stop_after_first = true }

NVTypeScript = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                vtsls = {
                    lsp = {
                        settings = {
                            typescript = lsp_settings,
                            javascript = lsp_settings,
                        },
                    },
                },
                prettierd = { lsp = false },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "javascript",
                "typescript",
                "tsx",
            },
        },
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                javascript = prettier,
                javascriptreact = prettier,
                typescript = prettier,
                typescriptreact = prettier,
            },
        },
    },
}

return NVTypeScript
