-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local o = vim.o
local g = vim.g
local opt = vim.opt

opt.termguicolors = true

opt.number = true
opt.relativenumber = false

opt.expandtab = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4

opt.list = true
opt.listchars = {
    tab = "▸ ",
    trail = "·",
    precedes = "←",
    extends = "→",
    nbsp = "+",
    -- eol = "↲",
}

opt.fillchars:append({
    vert = " ",
    eob = " ",
    diff = "",
})

opt.ignorecase = true
opt.smartcase = true

opt.mouse = "a"

opt.splitright = true
opt.splitbelow = true
opt.equalalways = true

opt.wrap = false

opt.whichwrap:append({
    ["<"] = true,
    [">"] = true,
    ["["] = true,
    ["]"] = true,
    h = true,
    l = true,
})

g.lazyvim_picker = "telescope"

if g.neovide then
    o.guifont = "BerkeleyMono Nerd Font:h17"
    opt.linespace = 24

    vim.g.neovide_padding_top = 0 -- Set to 40 if the tabline is hidden
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 30
    vim.g.neovide_padding_left = 30

    vim.g.neovide_scroll_animation_length = 0.2

    vim.g.neovide_floating_shadow = true
    vim.g.neovide_floating_z_height = 1
    vim.g.neovide_light_angle_degrees = 45
    vim.g.neovide_light_radius = 1

    vim.g.neovide_floating_blur_amount_x = 100
    vim.g.neovide_floating_blur_amount_y = 100

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
