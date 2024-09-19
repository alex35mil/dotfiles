return {
    {
        name = "theme",
        dir = vim.fn.stdpath("config") .. "/lua/theme",
        dev = true,
        lazy = false,
        priority = 1000,
        dependencies = { "rktjmp/lush.nvim" },
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "theme",
            icons = {
                diagnostics = {
                    Error = " ",
                    Warn = " ",
                    Hint = " ",
                    Info = " ",
                },
            },
        },
    },
}
