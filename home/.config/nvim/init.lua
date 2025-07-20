require("utils")
require("theme")
require("screen")
require("keymaps")
require("editor")
require("options")
require("plugins")

-- Theme

NVTheme.apply()

-- Keymaps

NVEditing.keymaps()
NVBuffers.keymaps()
NVWindows.keymaps()
NVTabs.keymaps()
NVNavigation.keymaps()
NVTerminal.keymaps()
NVDebug.keymaps()

-- Autocmds

NVLsp.autocmds()
NVTabs.autocmds()
NVGrugFar.autocmds()
NVPersistence.autocmds()
NVReScript.autocmds()
