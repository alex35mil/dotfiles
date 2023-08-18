local M = {}

M.default_width = 120
M.scratchpad_filename = "SIDENOTES"
M.scratchpad_filetype = "md"

function M.setup()
    local plugin = require "no-neck-pain"

    local sideBufOpts = {
        enabled = true,
        bo = {
            filetype = M.scratchpad_filetype,
            buftype = "nofile",
            bufhidden = "hide",
            buflisted = false,
            swapfile = false,
        },
    }

    plugin.setup {
        width = M.default_width,

        autocmds = {
            enableOnVimEnter = true,
            enableOnTabEnter = false,
            reloadOnColorSchemeChange = false,
        },

        mappings = {
            enabled = false,
        },

        buffers = {
            left = sideBufOpts,
            right = sideBufOpts,
            scratchPad = {
                enabled = true,
                fileName = M.scratchpad_filename,
            },
        },

        integrations = {
            NeoTree = {
                reopen = false,
            },
        },
    }
end

return M
