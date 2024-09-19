K = {}

NVKeymaps = {
    scroll = {
        up = "<D-Up>",
        down = "<D-Down>",
    },
    close = "<D-w>",
}

NVKarabiner = {
    ["<D-h>"] = "<C-A-h>",
    ["<D-m>"] = "<C-A-m>",
}

local default_keymap_options = { noremap = true, silent = true }

function K.map(mapping)
    -- NB!: it is important to remove items in reverse order to avoid shifting
    local cmd = table.remove(mapping, 3)
    local desc = table.remove(mapping, 2)
    local key = table.remove(mapping, 1)

    local mode = mapping["mode"]

    mapping["mode"] = nil
    mapping["desc"] = desc

    local options = vim.tbl_extend("force", default_keymap_options, mapping)

    vim.keymap.set(mode, key, cmd, options)
end
