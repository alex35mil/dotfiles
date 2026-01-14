NVLTerraform = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                terraformls = { lsp = true },
                tflint = { lsp = false },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "terraform",
                "hcl",
            },
        },
    },

    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                terraform = { "tflint" },
            },
            linters = {
                tflint = {
                    prepend_args = { "--fast" },
                },
            },
        },
    },

    {
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            local null_ls = require("null-ls")
            opts.sources = vim.list_extend(opts.sources or {}, {
                null_ls.builtins.diagnostics.terraform_validate,
                null_ls.builtins.formatting.terraform_fmt.with({
                    extra_filetypes = { "hcl" },
                }),
            })
        end,
    },
}

return NVLTerraform
