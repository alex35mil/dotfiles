NVLJSON = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                jsonls = {
                    lsp = {
                        settings = {
                            json = {
                                format = { enable = true },
                                validate = { enable = true },
                                schemas = require("schemastore").json.schemas(),
                                schemaDownload = { enable = true },
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
                "json",
                "json5",
                "jsonc",
            },
        },
    },
}

return NVLJSON
