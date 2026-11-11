NVPiton = {
    name = "piton",
    dir = "/Users/Alex/Projects/personal/tooling/piton/nvim",
    dependencies = {
        "pi.nvim",
        "folke/snacks.nvim",
    },
    opts = {
        tabs = {
            new = function()
                NVTabs.new()
            end,
            set_label = function(label)
                NVTabs.set_label(label)
            end,
        },
        icons = {
            agent = "󰙅",
            source = NVTabs.editor_icon,
        },
        confirm = function(message)
            return NVDialogs.confirm(message, "&Yes\n&No", 2) == 1
        end,
    },
    keys = function()
        return {
            {
                "<C-S-n>",
                function()
                    require("piton").new()
                end,
                mode = { "n", "i", "v", "t" },
                desc = "New agent",
            },
            {
                "<C-S-t>",
                function()
                    require("piton").pick()
                end,
                mode = { "n", "i", "v", "t" },
                desc = "Show agent picker",
            },
        }
    end,
}

return { NVPiton }
