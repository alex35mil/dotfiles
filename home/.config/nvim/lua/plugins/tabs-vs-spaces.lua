local M = {}

function M.setup()
    local plugin = require "tabs-vs-spaces"

    plugin.setup {
        indentation = "spaces",
        highlight = "TabsVsSpaces",
        priority = 20,
        ignore = {
            filetypes = {},
            buftypes = {
                "acwrite",
                "help",
                "nofile",
                "nowrite",
                "quickfix",
                "terminal",
                "prompt",
            },
        },
        standartize_on_save = false,
        user_commands = true,
    }
end

return M
