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

function NVMarkdown.autocmds()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true -- wrap at word boundaries
        end,
    })
end

return NVMarkdown
