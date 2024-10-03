NVDressing = {
    "stevearc/dressing.nvim",
    opts = {
        input = {
            relative = "cursor",
            border = "solid",
            mappings = {
                n = {
                    [NVKeymaps.close] = "Close",
                    ["<Esc>"] = "Close",
                    ["<CR>"] = "Confirm",
                },
                i = {
                    [NVKeymaps.close] = "Close",
                    ["<CR>"] = "Confirm",
                    ["<Up>"] = "HistoryPrev",
                    ["<Down>"] = "HistoryNext",
                },
            },
        },
        select = {
            backend = { "builtin" },
            builtin = {
                border = "solid",
                relative = "cursor",
                show_numbers = false,
                buf_options = {},
                win_options = {
                    cursorline = true,
                    cursorlineopt = "both",
                },

                width = nil,
                height = nil,
                max_width = { 140, 0.8 },
                min_width = { 30, 0.2 },
                max_height = 0.8,
                min_height = 2,

                mappings = {
                    [NVKeymaps.close] = "Close",
                    ["<Esc>"] = "Close",
                    ["<CR>"] = "Confirm",
                },
            },
        },
    },
}

return { NVDressing }
