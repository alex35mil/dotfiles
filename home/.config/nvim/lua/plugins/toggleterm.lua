local M = {}
local m = {}

function M.setup()
    local plugin = require "toggleterm"

    plugin.setup {
        shade_terminals = false,
    }
end

function M.keymaps()
    K.mapseq { "<M-t>t", "Toggle tab terminal", m.toggle_tab, mode = { "n", "i", "v", "t" } }
    K.mapseq { "<M-t>f", "Toggle float terminal", m.toggle_float, mode = { "n", "i", "v", "t" } }
    K.mapseq { "<M-t>h", "Toggle horizontal terminal", m.toggle_horizontal, mode = { "n", "i", "v", "t" } }
end

function M.ensure_active_hidden()
    local active_term = m.get_active()

    if active_term ~= nil then
        m.hide(active_term)
        return true
    else
        return false
    end
end

function M.ensure_any_hidden()
    local term = m.get_active()

    if term == nil then return end

    m.hide(term)
end

-- Private

function m.toggle_tab_cmd()
    vim.cmd "ToggleTerm direction=tab"
end

function m.toggle_float_cmd()
    vim.cmd "ToggleTerm direction=float"
end

function m.toggle_horizontal_cmd()
    vim.cmd "ToggleTerm direction=horizontal"
end

function m.toggle_tab()
    local active_term = m.get_active()

    if active_term ~= nil then
        m.hide(active_term)
    else
        local lualine = require "plugins.lualine"
        local zenmode = require "plugins.zen-mode"

        zenmode.ensure_deacitvated()
        m.toggle_tab_cmd()
        lualine.rename_tab "terminal"
    end
end

function m.toggle_float()
    local active_term = m.get_active()

    if active_term ~= nil then
        m.hide(active_term)
    else
        m.toggle_float_cmd()
    end
end

function m.toggle_horizontal()
    local active_term = m.get_active()

    if active_term ~= nil then
        m.hide(active_term)
    else
        local zenmode = require "plugins.zen-mode"

        zenmode.ensure_deacitvated()
        m.toggle_horizontal_cmd()
    end
end

function m.get_active()
    local terms = require("toggleterm.terminal").get_all()
    local current_window = vim.api.nvim_get_current_win()

    for _, term in pairs(terms) do
        if term.window == current_window then
            return term
        end
    end

    return nil
end

function m.hide(term)
    if term.direction == "tab" then
        m.toggle_tab_cmd()
    elseif term.direction == "float" then
        m.toggle_float_cmd()
    elseif term.direction == "horizontal" then
        m.toggle_horizontal_cmd()
    end
end

return M
