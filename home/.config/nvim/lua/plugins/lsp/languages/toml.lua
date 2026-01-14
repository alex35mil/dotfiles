NVLTOML = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                taplo = { lsp = true },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "toml",
            },
        },
    },
}

return NVLTOML
