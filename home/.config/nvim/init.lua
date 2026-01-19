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
NVFocusMode.keymaps()
NVDebug.keymaps()
NVGitCommit.keymaps()
NVGitWorktrees.keymaps()

-- Autocmds

NVLspPopup.autocmds()
NVBuffers.autocmds()
NVLayoutManager.autocmds()
NVFocusMode.autocmds()
NVGrugFar.autocmds()
NVPersistence.autocmds()
NVBlinkCmp.autocmds()
NVOil.autocmds()
NVLReScript.autocmds()
NVLMarkdown.autocmds()
