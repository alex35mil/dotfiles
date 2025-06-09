NVWinshift = {
    "sindrets/winshift.nvim",
    event = "VimEnter",
    opts = {
        highlight_moving_win = true,
        focused_hl_group = "WinShiftMove",
        moving_win_options = {
            -- These are local options applied to the moving window while it's being moved.
            -- They are unset when you leave Win-Move mode.
            wrap = false,
            cursorline = false,
            cursorcolumn = false,
            colorcolumn = "",
        },
        keymaps = {
            disable_defaults = true,
            win_move_mode = {
                ["d"] = "left",
                ["h"] = "down",
                ["t"] = "up",
                ["n"] = "right",
                ["D"] = "far_left",
                ["H"] = "far_down",
                ["T"] = "far_up",
                ["N"] = "far_right",
                ["<Left>"] = "left",
                ["<Down>"] = "down",
                ["<Up>"] = "up",
                ["<Right>"] = "right",
                ["<S-Left>"] = "far_left",
                ["<S-Down>"] = "far_down",
                ["<S-Up>"] = "far_up",
                ["<S-Right>"] = "far_right",
            },
        },
        window_picker = function()
            return require("winshift.lib").pick_window({
                picker_chars = NVWindows.window_picker_keys,
                filter_rules = {
                    cur_win = true, -- Filter out the current window
                    floats = true, -- Filter out floating windows
                    filetype = {}, -- List of ignored file types
                    buftype = {}, -- List of ignored buftypes
                    bufname = {}, -- List of vim regex patterns matching ignored buffer names
                },
                filter_func = nil,
            })
        end,
    },
}

function NVWinshift.move()
    vim.cmd("WinShift")
end

function NVWinshift.move_right()
    vim.cmd("WinShift right")
end

function NVWinshift.move_left()
    vim.cmd("WinShift left")
end

function NVWinshift.move_up()
    vim.cmd("WinShift up")
end

function NVWinshift.move_down()
    vim.cmd("WinShift down")
end

function NVWinshift.swap()
    vim.cmd("WinShift swap")
end

return { NVWinshift }
