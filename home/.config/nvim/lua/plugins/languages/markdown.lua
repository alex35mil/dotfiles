local CONFIG = os.getenv("XDG_CONFIG_HOME")

NVMarkdown = {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
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
