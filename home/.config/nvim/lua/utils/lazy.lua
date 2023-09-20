local M = {}

function M.is_active()
    return vim.bo.filetype == "lazy"
end

function M.close()
    local keys = require "utils.keys"
    keys.send("q", { mode = "x" })
end

return M