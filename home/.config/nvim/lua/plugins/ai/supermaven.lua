NVSupermaven = {
    "supermaven-inc/supermaven-nvim",
    opts = {
        disable_keymaps = true,
        disable_inline_completion = true,
    },
}

NVBlinkCmpSupermaven = {
    "saghen/blink.cmp",
    dependencies = {
        "supermaven-inc/supermaven-nvim",
        "alex35mil/blink-cmp-supermaven",
    },
    opts = {
        sources = {
            providers = {
                supermaven = {
                    name = "supermaven",
                    module = "blink-cmp-supermaven",
                },
            },
        },
    },
}

return { NVSupermaven, NVBlinkCmpSupermaven }
