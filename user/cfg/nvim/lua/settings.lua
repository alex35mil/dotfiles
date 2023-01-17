local g = vim.g
local opt = vim.opt

opt.termguicolors = true

opt.number = true
opt.relativenumber = false -- `<N>j` is not a jump, so I prefer to `hop`

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

opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

opt.timeout = true
opt.timeoutlen = 500

opt.splitright = true
opt.splitbelow = true

opt.whichwrap:append {
    ["<"] = true,
    [">"] = true,
    ["["] = true,
    ["]"] = true,
    h = true,
    l = true,
}

opt.autowrite = true
opt.autowriteall = true

g.loadednetrw = 1
g.loaded_netrwPlugin = 1
