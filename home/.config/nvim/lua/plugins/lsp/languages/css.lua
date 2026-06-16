NVLCss = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                stylelint_lsp = { lsp = true },
                css_variables = { lsp = true },
            },
        },
    },

    {
        "romus204/tree-sitter-manager.nvim",
        opts = {
            ensure_installed = {
                "css",
            },
        },
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                css = { "oxfmt" },
            },
        },
    },

    {
        "nvim-tree/nvim-web-devicons",
        opts = {
            override = {
                css = {
                    icon = "",
                    color = "#1572b6",
                    name = "CSS",
                },
            },
        },
    },
}

return NVLCss
