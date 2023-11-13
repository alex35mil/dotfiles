local M = {}
local m = {}

function M.keymaps()
    K.map { "<C-q>", "Quit editor", m.quit, mode = { "n", "i", "v", "t" } } -- It's <D-q> remapped via Karabiner
end

-- Private

function m.quit()
    local lazy = require "plugins.lazy"
    local noice = require "plugins.noice"
    local zenmode = require "plugins.zen-mode"
    local spectre = require "plugins.spectre"
    local filetree = require "plugins.neo-tree"
    local toggleterm = require "plugins.toggleterm"
    local mason = require "plugins.lsp.mason"
    local lazygit = require "plugins.git.lazygit"
    local diffview = require "plugins.git.diffview"

    local mode = vim.fn.mode()

    if mode == "i" or mode == "v" then
        local keys = require "editor.keys"
        keys.send("<Esc>", { mode = "x" })
    end

    lazy.ensure_hidden()
    noice.ensure_hidden()
    zenmode.ensure_deacitvated()
    spectre.ensure_any_closed()
    filetree.ensure_any_hidden()
    toggleterm.ensure_any_hidden()
    mason.ensure_hidden()
    lazygit.ensure_hidden()
    diffview.ensure_all_hidden()

    -- NOTE: Not `wqa` due to toggleterm issue
    vim.cmd "wa"
    vim.cmd "qa"
end

return M
