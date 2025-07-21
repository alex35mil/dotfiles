NVTerraform = {
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
        },
    },

    {
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            local null_ls = require("null-ls")
            opts.sources = vim.list_extend(opts.sources or {}, {
                null_ls.builtins.diagnostics.terraform_validate,
            })
        end,
    },
}

return NVTerraform
