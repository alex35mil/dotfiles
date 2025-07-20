NVCss = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            ensure_installed = {
                "stylelint-lsp",
                "css-variables-language-server",
            },
            setup = {
                stylelint_lsp = function(_, opts)
                    opts.filetypes = { "css" }
                end,
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "css",
            },
        },
    },
}

return NVCss
