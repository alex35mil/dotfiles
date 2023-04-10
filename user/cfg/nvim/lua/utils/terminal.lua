local M = {}

function M.toggle_tab()
    vim.cmd "ToggleTerm direction=tab"
end

function M.toggle_float()
    vim.cmd "ToggleTerm direction=float"
end

function M.get_active()
    local terms = require("toggleterm.terminal").get_all()
    local current_window = vim.api.nvim_get_current_win()

    for _, term in pairs(terms) do
        if term.window == current_window then
            return term
        end
    end

    return nil
end

function M.is_active()
    return M.get_active() ~= nil
end

function M.hide(term)
    if term.direction == "tab" then
        M.toggle_tab()
    elseif term.direction == "float" then
        M.toggle_float()
    end
end

function M.ensure_hidden()
    local term = M.get_active()

    if term == nil then return end

    M.hide(term)
end

return M
