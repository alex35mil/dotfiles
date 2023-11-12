local M = {}

function M.setup()
    local plugin = require "window-picker"
    local windows = require "editor.windows"
    local colors = require "theme.palette"

    plugin.setup {
        selection_chars = windows.window_picker_keys,
        filter_rules = {
            autoselect_one = true,
            include_current_win = false,
            bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { "neo-tree", "neo-tree-popup", "notify" },

                -- if the buffer type is one of following, the window will be ignored
                buftype = { "terminal", "quickfix" },
            },
        },
        highlights = {
            statusline = {
                focused = {
                    fg = colors.bg,
                    bg = colors.cyan,
                    bold = true,
                },
                unfocused = {
                    fg = colors.bg,
                    bg = colors.cyan,
                    bold = true,
                },
            },
            winbar = {
                focused = {
                    fg = colors.bg,
                    bg = colors.cyan,
                    bold = true,
                },
                unfocused = {
                    fg = colors.bg,
                    bg = colors.cyan,
                    bold = true,
                },
            },
        },
    }
end

return M
