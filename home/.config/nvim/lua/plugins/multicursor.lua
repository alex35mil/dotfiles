NVMulticursor = {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = {
        {
            "<C-Up>",
            function()
                require("multicursor-nvim").lineAddCursor(-1)
            end,
            mode = { "n", "v" },
        },
        {
            "<C-Down>",
            function()
                require("multicursor-nvim").lineAddCursor(1)
            end,
            mode = { "n", "v" },
        },
        {
            "<C-S-Up>",
            function()
                require("multicursor-nvim").lineSkipCursor(-1)
            end,
            mode = { "n", "v" },
        },
        {
            "<C-S-Down>",
            function()
                require("multicursor-nvim").lineSkipCursor(1)
            end,
            mode = { "n", "v" },
        },
        {
            "<C-Space>",
            function()
                require("multicursor-nvim").toggleCursor()
            end,
            mode = { "n", "v" },
            desc = "Multicursor: Add and remove cursors using the main cursor",
        },
        {
            "<C-o>", -- TODO: Change
            function()
                local mc = require("multicursor-nvim")
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                end
            end,
            mode = { "n", "v" },
            desc = "Multicursor: Enable cursors",
        },
        {
            "I",
            function()
                require("multicursor-nvim").insertVisual()
            end,
            mode = "v",
            desc = "Multicursor: Insert for each line of visual selections",
        },
        {
            "A",
            function()
                require("multicursor-nvim").appendVisual()
            end,
            mode = "v",
            desc = "Multicursor: Append for each line of visual selections",
        },
        {
            "<Leader>ca",
            function()
                require("multicursor-nvim").alignCursors()
            end,
            mode = "n",
            desc = "Multicursor: Align cursor columns",
        },
        {
            "<D-LeftMouse>",
            function()
                require("multicursor-nvim").handleMouse()
            end,
            mode = "n",
        },
        {
            "<Leader>gv",
            function()
                require("multicursor-nvim").restoreCursors()
            end,
            mode = "n",
            desc = "Multicursor: Bring back cursors if accidentally cleared them",
        },
    },
    config = function()
        require("multicursor-nvim").setup()
    end,
}

function NVMulticursor.esc()
    local mc = require("multicursor-nvim")

    if mc.hasCursors() then
        mc.clearCursors()
        return true
    else
        return false
    end
end

return { NVMulticursor }
