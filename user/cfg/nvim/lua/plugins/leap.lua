local plugin = require "leap"

plugin.add_default_mappings()

-- yes leap, I want my `x` back
vim.keymap.del({ "x", "o" }, "x")
vim.keymap.del({ "x", "o" }, "X")
