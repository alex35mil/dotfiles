NVMiniPairs = {
    "echasnovski/mini.pairs",
    opts = {
        mappings = {
            ['"'] = { action = "open", pair = '""', neigh_pattern = "[^\\][%s%)%]%}%,%.]" },
            ["'"] = { action = "open", pair = "''", neigh_pattern = "[^%a\\][%s%)%]%}%,%.]" },
            ["`"] = { action = "open", pair = "``", neigh_pattern = "[^\\][%s%)%]%}%,%.]" },
            ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][%s%)%]%}%,%.]" },
            ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][%s%)%]%}%,%.]" },
            ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][%s%)%]%}%,%.]" },
            [")"] = false,
            ["]"] = false,
            ["}"] = false,
        },
    },
}

return { NVMiniPairs }
