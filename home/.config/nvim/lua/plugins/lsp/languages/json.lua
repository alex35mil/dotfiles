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
        "romus204/tree-sitter-manager.nvim",
        opts = {
            ensure_installed = {
                "json",
                "json5",
            },
        },
    },
}

return NVLJSON
