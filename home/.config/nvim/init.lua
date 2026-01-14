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
NVFocus.keymaps()
NVDebug.keymaps()

-- Autocmds

NVLsp.autocmds()
NVBuffers.autocmds()
NVTabs.autocmds()
NVFocus.autocmds()
NVGrugFar.autocmds()
NVPersistence.autocmds()
NVBlinkCmp.autocmds()
NVOil.autocmds()
NVLReScript.autocmds()
NVLMarkdown.autocmds()
