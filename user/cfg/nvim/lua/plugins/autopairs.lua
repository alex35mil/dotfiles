local M = {}

function M.setup()
    local plugin = require "nvim-autopairs"

    plugin.setup {
        check_ts = true,
    }
end

return M
