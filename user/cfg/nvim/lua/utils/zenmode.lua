local M = {}

local plugin = require "zen-mode"

function M.toggle()
    if M.is_active() then
        M.deactivate()
    else
        M.activate()
    end
end

function M.activate()
    if not M.is_active() then
        plugin.toggle()
    end
end

function M.deactivate()
    local zen_buf = vim.api.nvim_get_current_buf()

    plugin.toggle()

    local current_buf = vim.api.nvim_get_current_buf()

    if current_buf == zen_buf then
        return
    end

    vim.api.nvim_set_current_buf(zen_buf)
end

function M.is_active()
    local zenmode = require "zen-mode.view"
    local is_open = zenmode.is_open()

    if is_open == nil then
        return false
    else
        return is_open
    end
end

function M.parent_window()
    local zenmode = require "zen-mode.view"
    return zenmode.parent
end

function M.ensure_deacitvated()
    if M.is_active() then
        M.deactivate()
    end
end

return M
