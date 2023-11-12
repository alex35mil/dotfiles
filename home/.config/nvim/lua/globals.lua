-- Keymaps

_G.K = {}

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

function K.mapseq(mapping)
    local wk = require "which-key"

    local keymap = {}

    -- NB!: it is important to remove items in reverse order to avoid shifting
    local cmd = table.remove(mapping, 3)
    local desc = table.remove(mapping, 2)
    local key = table.remove(mapping, 1)

    mapping[1] = cmd
    mapping[2] = desc

    keymap[key] = mapping

    wk.register(keymap, default_keymap_options)
end
