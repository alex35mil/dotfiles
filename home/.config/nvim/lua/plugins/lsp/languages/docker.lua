NVDocker = {
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
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "dockerfile",
            },
        },
    },
}

return NVDocker
