local M = {}

function M.is_active()
    return vim.bo.filetype == "spectre_panel"
end

function M.close()
    require("spectre").close()
end

function M.ensure_closed()
    local state = require "spectre.state"
    if state.bufnr ~= nil then
        M.close()
    end
end

return M
