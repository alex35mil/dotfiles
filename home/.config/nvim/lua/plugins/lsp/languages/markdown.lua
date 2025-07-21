local CONFIG = os.getenv("XDG_CONFIG_HOME")

NVMarkdown = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                ["markdownlint-cli2"] = { lsp = false },
            },
        },
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        opts = {
            code = {
                enabled = false,
            },
            heading = {
                sign = true,
            },
            checkbox = {
                enabled = false,
            },
        },
    },

    {
        "mfussenegger/nvim-lint",
        opts = {
            linters = {
                ["markdownlint-cli2"] = {
                    args = { "--config", CONFIG .. "/.markdownlint.yaml", "--" },
                },
            },
        },
    },
}

return NVMarkdown
