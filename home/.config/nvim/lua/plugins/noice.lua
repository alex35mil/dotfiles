local fn = {}

NVNoice = {
    "folke/noice.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    keys = function()
        return {
            { "<D-l>", "<Cmd>NoiceHistory<CR>", mode = { "n", "i", "v" }, desc = "Open log" },
        }
    end,
    opts = function()
        local Layout = {
            common = {
                position = {
                    visually_centered = {
                        row = "40%",
                        col = "50%",
                    },
                },
                border = {
                    style = "none",
                    padding = { top = 1, bottom = 1, left = 2, right = 2 },
                },
                win_options = {
                    winhighlight = {
                        Normal = "NormalFloat",
                        FloatBorder = "FloatBorder",
                    },
                    winbar = "",
                    foldenable = false,
                },
            },
            cmdline_popup = {
                position = {
                    row = 10,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
        }

        return {
            cmdline = {
                format = {
                    search_down = { view = "cmdline" },
                    search_up = { view = "cmdline" },
                },
            },

            status = {
                lsp_progress = {
                    event = "lsp",
                    kind = "progress",
                },
            },

            commands = {
                last = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = "notify" },
                            { error = true },
                            { warning = true },
                            { event = "msg_show", kind = { "" } },
                            { event = "lsp", kind = "message" },
                        },
                    },
                    filter_opts = { count = 1 },
                },
                history = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = "notify" },
                            { error = true },
                            { warning = true },
                            { event = "msg_show", kind = { "" } },
                            { event = "lsp", kind = "message" },
                        },
                    },
                },
                errors = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = { error = true },
                    filter_opts = { reverse = true },
                },
                all = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {},
                },
            },

            views = {
                popup = {
                    backend = "popup",
                    relative = "editor",
                    position = Layout.common.position.visually_centered,
                    border = Layout.common.border,
                    size = {
                        width = NVWindows.default_width,
                        height = NVScreen.is_large() and 30 or 15,
                    },
                    win_options = Layout.common.win_options,
                    close = {
                        events = { "BufLeave" },
                        keys = { NVKeymaps.close },
                    },
                },
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
                    position = Layout.cmdline_popup.position,
                    size = Layout.cmdline_popup.size,
                    border = Layout.common.border,
                    win_options = Layout.common.win_options,
                    filter_options = {},
                    close = { keys = { NVKeymaps.close } },
                },
                cmdline_popupmenu = {
                    position = {
                        row = Layout.cmdline_popup.position.row + 4,
                        col = Layout.cmdline_popup.position.col,
                    },
                    size = Layout.cmdline_popup.size,
                    border = Layout.common.border,
                    win_options = Layout.common.win_options,
                    close = { keys = { NVKeymaps.close } },
                },
                cmdline_output = {
                    enter = true,
                    format = "details",
                    view = "popup",
                },
                notify = {
                    backend = "notify",
                    render = "wrapped-compact",
                },
            },

            routes = {
                {
                    filter = { event = "lsp", kind = "progress" },
                    opts = { skip = true },
                },
            },
        }
    end,
    config = function(_, opts)
        require("noice").setup(opts)
        require("telescope").load_extension("noice")
    end,
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
