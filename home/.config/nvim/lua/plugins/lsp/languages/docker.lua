NVLDocker = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                dockerls = {
                    lsp = {
                        settings = {
                            docker = {
                                languageserver = {
                                    formatter = {
                                        ignoreMultilineInstructions = true,
                                    },
                                },
                            },
                        },
                    },
                },
                docker_compose_language_service = { lsp = true },
                hadolint = { lsp = false },
            },
        },
    },

    {
        "romus204/tree-sitter-manager.nvim",
        opts = {
            ensure_installed = {
                "dockerfile",
            },
        },
    },
}

return NVLDocker
