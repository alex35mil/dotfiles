NVSupermaven = {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
        log_level = "off",
        disable_keymaps = true,
        disable_inline_completion = false,
    },
    config = function(_, opts)
        require("supermaven-nvim").setup(opts)
        require("supermaven-nvim.completion_preview").disable_inline_completion = true
    end,
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
