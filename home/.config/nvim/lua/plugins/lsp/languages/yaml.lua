NVLYAML = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                yamlls = {
                    lsp = {
                        settings = {
                            yaml = {
                                schemas = require("schemastore").yaml.schemas(),
                                schemaStore = { enable = false, url = "" },
                            },
                            redhat = { telemetry = { enabled = false } },
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
                "yaml",
            },
        },
    },
}

return NVLYAML
