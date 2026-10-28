NVLSwift = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                -- sourcekit-lsp ships with Xcode, so Mason doesn't manage it
                sourcekit = {
                    lsp = {
                        -- Defaults also include C/C++; keep sourcekit-lsp scoped to Swift and Objective-C
                        filetypes = { "swift", "objc", "objcpp" },
                    },
                    mason = false,
                },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "swift",
            },
        },
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                -- `swift format` from the Xcode toolchain
                swift = { "swift" },
            },
        },
    },
}

return NVLSwift
