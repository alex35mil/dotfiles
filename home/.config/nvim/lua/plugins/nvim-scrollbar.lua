NVScrollbar = {
    "petertriho/nvim-scrollbar",
    event = "BufEnter",
    opts = {
        show = true,
        handlers = {
            cursor = false,
            diagnostic = true,
            gitsigns = false, -- Requires gitsigns
            handle = true,
            search = false, -- Requires hlslens
            ale = false,
        },
        excluded_filetypes = {
            "snacks_picker_list",
        },
    },
}

return { NVScrollbar }
