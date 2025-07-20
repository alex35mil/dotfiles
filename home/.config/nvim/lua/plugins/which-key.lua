NVWhichKey = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "helix",
        -- NOTE: It doesn't work as it interferes with general scroll keymaps
        -- keys = {
        --     scroll_up = NVKeymaps.scroll.up,
        --     scroll_down = NVKeymaps.scroll.down,
        -- },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}

return { NVWhichKey }
