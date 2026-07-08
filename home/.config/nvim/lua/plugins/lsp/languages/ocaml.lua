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
        "romus204/tree-sitter-manager.nvim",
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
