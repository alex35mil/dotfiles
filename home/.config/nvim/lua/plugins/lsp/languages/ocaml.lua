NVLOCaml = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                ocamllsp = { lsp = true, mason = false },
                ocamlformat = { lsp = false, mason = false },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "menhir",
                "ocaml",
                "ocaml_interface",
                "ocamllex",
            },
        },
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                ocaml = { "ocamlformat" },
                ocamlinterface = { "ocamlformat" },
            },
        },
    },
}

return NVLOCaml
