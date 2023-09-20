local M = {}

function M.setup()
    local plugin = require "auto-session"

    plugin.setup {
        log_level = "error",
        auto_session_create_enabled = true,
        auto_save_enabled = true,
        auto_restore_enabled = true,
        auto_session_enable_last_session = false,
        auto_session_suppress_dirs = { "~/" },
    }
end

return M
