NVScrollbar = {
    "petertriho/nvim-scrollbar",
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
    },
}

return { NVScrollbar }
