NVTypeScript = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            ensure_installed = {
                "vtsls",
            },
            servers = {
                vtsls = {
                    settings = {
                        typescript = {
                            preferences = {
                                quoteStyle = "double",
                            },
                            format = {
                                enable = true,
                                semicolons = "remove",
                            },
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
                "typescript",
            },
        },
    },
}

return NVTypeScript
