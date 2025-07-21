NVSQL = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                sqlfluff = { lsp = false },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "sql",
            },
        },
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                sql = { "sqlfluff" },
            },
            formatters = {
                sqlfluff = {
                    args = { "format", "--dialect=ansi", "-" },
                },
            },
        },
    },
}

return NVSQL
