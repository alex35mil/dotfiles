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
NVHooked.keymaps()
NVNavigation.keymaps()
NVTerminal.keymaps()
NVDebug.keymaps()

-- Autocmds

NVLsp.autocmds()
NVBuffers.autocmds()
NVTabs.autocmds()
NVGrugFar.autocmds()
NVPersistence.autocmds()
NVBlinkCmp.autocmds()
NVReScript.autocmds()
NVHooked.autocmds()
