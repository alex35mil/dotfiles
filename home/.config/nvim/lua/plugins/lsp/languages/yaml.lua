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
        "romus204/tree-sitter-manager.nvim",
        opts = {
            ensure_installed = {
                "yaml",
            },
        },
    },
}

return NVLYAML
