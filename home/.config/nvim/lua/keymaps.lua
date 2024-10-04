K = {}

NVKeymaps = {
    scroll = {
        up = "<D-Up>",
        down = "<D-Down>",
    },
    rename = "<D-r>",
    close = "<D-w>",
}

NVKarabiner = {
    ["<D-h>"] = "<C-A-h>",
    ["<D-m>"] = "<C-A-m>",
}

local default_keymap_options = { noremap = true, silent = true }

---@class Keymap
---@field [1] string Keymap
---@field [2] string Description
---@field [3] string | function Action
---@field mode Mode | Mode[] Mode

---@alias Mode "n"|"v"|"i"|"c"|"s"|"o"|"t"|"x"

---@param mapping Keymap
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
