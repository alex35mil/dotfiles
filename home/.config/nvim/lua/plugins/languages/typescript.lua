NVTypeScript = {
    {
        "neovim/nvim-lspconfig",
        opts = {
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
}

return NVTypeScript
