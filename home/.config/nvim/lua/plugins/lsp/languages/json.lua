NVJSON = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            ensure_installed = {
                "json-lsp",
            },
            servers = {
                jsonls = {
                    settings = {
                        json = {
                            format = {
                                enable = true,
                            },
                            validate = { enable = true },
                        },
                    },
                },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "json",
                "jsonc",
            },
        },
    },
}

return NVJSON
