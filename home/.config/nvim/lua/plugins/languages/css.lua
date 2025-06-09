NVCss = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            setup = {
                stylelint_lsp = function(_, opts)
                    opts.filetypes = { "css" }
                end,
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylelint-lsp",
                "css-variables-language-server",
            },
        },
    },
}

return NVCss
