local fn = {}

NVNoice = {
    "folke/noice.nvim",
    opts = {
        cmdline = {
            format = {
                search_down = { view = "cmdline" },
                search_up = { view = "cmdline" },
            },
        },
        views = {
            cmdline = {
                position = {
                    row = 0,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 1,
                },
            },
            cmdline_popup = {
                position = {
                    row = "30%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
            cmdline_output = {
                enter = true,
            },
        },
    },
}

function NVNoice.ensure_hidden()
    if fn.is_cmdline_active() then
        fn.exit_cmdline()
        return true
    end

    local current_win = vim.api.nvim_get_current_win()

    if fn.is_win_active() then
        if NVWindows.is_window_floating(current_win) then
            fn.close_split()
            return true
        else
            if NVNoNeckPain.are_sidepads_visible() then
                NVNoNeckPain.update_layout_with(function()
                    vim.api.nvim_set_current_win(current_win)
                    fn.close_split()
                end, { check_sidepads_visibility = false })
            else
                fn.close_split()
            end

            return true
        end
    else
        return false
    end
end

function fn.is_win_active()
    return vim.bo.filetype == "noice"
end

function fn.is_cmdline_active()
    local mode = vim.fn.mode()
    return mode == "c"
end

function fn.close_split()
    vim.cmd.close()
end

function fn.exit_cmdline()
    NVKeys.send("<Esc>", { mode = "n" })
end

return { NVNoice }
