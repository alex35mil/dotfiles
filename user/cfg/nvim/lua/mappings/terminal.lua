local M = {}

function M.toggle_tab()
    local term = require "utils.terminal"

    local active_term = term.get_active()

    if active_term ~= nil then
        term.hide(active_term)
    else
        local zenmode = require "utils.zenmode"
        local statusline = require "utils.statusline"

        zenmode.ensure_deacitvated()
        term.toggle_tab()
        statusline.rename_tab("terminal")
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
    return vim.api.nvim_replace_termcodes(
        [[<Cmd>lua vim.api.nvim_put({ vim.fn.getreg("*") }, "c", false, true)<CR>]],
        true,
        true,
        true
    )
end

return M
