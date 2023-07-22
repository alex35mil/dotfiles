local g = vim.g
local opt = vim.opt

opt.termguicolors = true

opt.number = true
opt.relativenumber = false -- `<N>j` is not a jump, so I prefer to `pounce`

opt.cursorline = true
opt.cursorcolumn = false
opt.colorcolumn = "80,120"
opt.signcolumn = "yes:1"

opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"

opt.expandtab = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4

opt.fillchars = { eob = " ", diff = "" }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

opt.timeout = true
opt.timeoutlen = 500

opt.splitright = true
opt.splitbelow = true
opt.equalalways = true

opt.showtabline = 1

opt.wrap = false

opt.whichwrap:append {
    ["<"] = true,
    [">"] = true,
    ["["] = true,
    ["]"] = true,
    h = true,
    l = true,
}

opt.autoread = true
opt.autowrite = true
opt.autowriteall = true

opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

g.loadednetrw = 1
g.loaded_netrwPlugin = 1
