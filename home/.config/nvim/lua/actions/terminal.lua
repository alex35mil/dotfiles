local M = {}

function M.toggle_tab()
    local term = require "utils.terminal"

    local active_term = term.get_active()

    if active_term ~= nil then
        term.hide(active_term)
    else
        local zenmode = require "utils.zenmode"
        local tabline = require "utils.tabline"

        zenmode.ensure_deacitvated()
        term.toggle_tab()
        tabline.rename_tab("terminal")
    end
end

function M.toggle_horizontal()
    local term = require "utils.terminal"

    local active_term = term.get_active()

    if active_term ~= nil then
        term.hide(active_term)
    else
        local zenmode = require "utils.zenmode"

        zenmode.ensure_deacitvated()
        term.toggle_horizontal()
    end
end

function M.toggle_float()
    local term = require "utils.terminal"

    local active_term = term.get_active()

    if active_term ~= nil then
        term.hide(active_term)
    else
        term.toggle_float()
    end
end

function M.paste()
    local content = vim.fn.getreg("*")
    vim.api.nvim_put({ content }, "", true, true)
end

return M
