local lsp_settings = {
    preferences = {
        quoteStyle = "double",
    },
    format = {
        enable = false,
        semicolons = "remove",
    },
}

local oxfmt = { "oxfmt" }

NVLTypeScript = {
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
            },
        },
    },

    {
        "romus204/tree-sitter-manager.nvim",
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
                javascript = oxfmt,
                javascriptreact = oxfmt,
                typescript = oxfmt,
                typescriptreact = oxfmt,
            },
        },
    },
}

return NVLTypeScript
