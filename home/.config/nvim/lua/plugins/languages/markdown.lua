local CONFIG = os.getenv("XDG_CONFIG_HOME")

NVMarkdown = {
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
