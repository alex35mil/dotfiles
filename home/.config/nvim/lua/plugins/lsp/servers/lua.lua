local M = {}

function M.setup(config)
    local neodev = require "neodev"

    neodev.setup {}

    config.lua_ls.setup {
        settings = {
            Lua = {
                format = {
                    enable = true,
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    }
end

return M
