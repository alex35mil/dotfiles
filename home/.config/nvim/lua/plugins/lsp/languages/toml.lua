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
        "romus204/tree-sitter-manager.nvim",
        opts = {
            ensure_installed = {
                "toml",
            },
        },
    },
}

return NVLTOML
