vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.numberwidth = 4
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.timeoutlen = 500

vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

vim.opt.autowrite = true
vim.opt.autoread = true

vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.ruler = false

vim.opt.smoothscroll = true

vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.pumblend = 10
vim.opt.pumheight = 10

vim.opt.wildmode = "longest:full,full"

vim.opt.list = true
vim.opt.listchars = {
    tab = "▸ ",
    trail = "·",
    precedes = "←",
    extends = "→",
    nbsp = "+",
    -- eol = "↲",
}

vim.opt.fillchars:append({
    eob = " ",
    diff = "",
})

vim.opt.conceallevel = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.mouse = "a"

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.equalalways = true
vim.opt.splitkeep = "screen"

vim.opt.winminwidth = 5

vim.opt.inccommand = "nosplit"

vim.opt.wrap = false
vim.opt.linebreak = true

vim.o.foldenable = true
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.opt.shiftround = true

vim.opt.whichwrap:append({
    ["<"] = true,
    [">"] = true,
    ["["] = true,
    ["]"] = true,
    h = true,
    l = true,
})

vim.opt.jumpoptions = "view"

vim.opt.virtualedit = "block"

vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.formatoptions = "jcroqlnt"

vim.opt.spelllang = { "en" }

vim.opt.shortmess:append({
    W = true,
    I = true,
    c = true,
    C = true,
    S = true,
    s = true,
})

vim.opt.updatetime = 200

vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.confirm = true

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

vim.g.markdown_recommended_style = 0

if vim.g.neovide then
    vim.g.snacks_animate = false

    vim.o.guifont = "BerkeleyMono Nerd Font:h17"
    vim.opt.linespace = 24

    vim.g.neovide_padding_top = 0 -- Set to 40 if the tabline is hidden
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 30
    vim.g.neovide_padding_left = 30

    vim.g.neovide_scroll_animation_length = 0.2

    vim.g.neovide_floating_shadow = false
    vim.g.neovide_floating_z_height = 0
    vim.g.neovide_light_angle_degrees = 0
    vim.g.neovide_light_radius = 0

    vim.g.neovide_floating_blur_amount_x = 0
    vim.g.neovide_floating_blur_amount_y = 0

    vim.g.neovide_floating_corner_radius = 0.15

    vim.g.neovide_hide_mouse_when_typing = true

    vim.g.neovide_remember_window_size = true
    vim.g.neovide_confirm_quit = true

    vim.g.neovide_fullscreen = false

    vim.g.neovide_input_use_logo = true
    vim.g.neovide_input_macos_option_key_is_meta = "both"

    vim.g.neovide_cursor_antialiasing = false
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.g.neovide_cursor_animate_command_line = false
end
