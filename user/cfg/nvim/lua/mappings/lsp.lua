local diagnostic = require "lspsaga.diagnostic"
local severity = vim.diagnostic.severity

local M = {}

function M.jump_to_prev_warning()
    diagnostic:goto_prev({ severity = severity.WARN })
end

function M.jump_to_next_warning()
    diagnostic:goto_next({ severity = severity.WARN })
end

function M.jump_to_prev_error()
    diagnostic:goto_prev({ severity = severity.ERROR })
end

function M.jump_to_next_error()
    diagnostic:goto_next({ severity = severity.ERROR })
end

function M.toggle_lines()
    local lines = require "lsp_lines"
    local visible = lines.toggle()
    vim.diagnostic.config({ virtual_text = not visible })
end

return M
