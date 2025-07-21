NVBlinkCmp = {
    "saghen/blink.cmp",
    build = "cargo build --release",
    event = "InsertEnter",
    opts = {
        sources = {
            default = {
                "supermaven",
                "lsp",
                "path",
                "snippets",
                "buffer",
            },
        },
        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = false,
                },
            },
            documentation = { auto_show = true },
            ghost_text = { enabled = false },
        },
        cmdline = { enabled = false },
        keymap = {
            ["<CR>"] = { "accept", "fallback" },
            ["<M-Esc>"] = { "show_documentation", "hide_documentation", "fallback" },
            ["<D-c>"] = {
                function(cmp)
                    cmp.show({ providers = { "supermaven" } })
                end,
            },
            [NVKeymaps.scroll.up] = { "scroll_documentation_up", "fallback" },
            [NVKeymaps.scroll.down] = { "scroll_documentation_down", "fallback" },
            [NVKeymaps.close] = { "hide", "fallback" },
        },
    },
}

function NVBlinkCmp.autocmds()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "gitcommit",
        callback = function()
            vim.b.completion = false
        end,
    })
end

return { NVBlinkCmp }
