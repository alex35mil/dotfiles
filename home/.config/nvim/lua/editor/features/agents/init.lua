-- Agents: APFS copy-on-write clones of a repository, created next to it as
-- `<parent>/<repo>--<name>`, where pi.nvim runs Pi inside a nono sandbox
-- through a workspace descriptor.

local lookup = require("editor.features.agents.lookup")
local new = require("editor.features.agents.new")
local picker = require("editor.features.agents.picker")
local close = require("editor.features.agents.close")

NVAgents = {}

function NVAgents.keymaps()
    K.map({ "<C-S-n>", "New agent (from Todo or by name)", new.pick, mode = { "n", "i", "v", "t" } })
    K.map({ "<C-S-t>", "Show agent picker", picker.pick, mode = { "n", "i", "v", "t" } })
end

--- The agent containing `path`, or nil when it isn't inside one.
NVAgents.get = lookup.get

NVAgents.close_tab = close.close_tab
