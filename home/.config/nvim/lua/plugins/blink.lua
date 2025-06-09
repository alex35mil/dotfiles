NVBlink = {
    "saghen/blink.cmp",
    opts = {
        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = false,
                },
            },
            ghost_text = {
                enabled = false,
            },
        },

        keymap = {
            ["<CR>"] = { "accept", "fallback" },
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

return { NVBlink }
