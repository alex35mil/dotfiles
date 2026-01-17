local fn = {}

NVNoice = {
    "folke/noice.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    event = "VeryLazy",
    keys = function()
        return {
            { "<D-S-l>", "<Cmd>NoiceAll<CR>", mode = { "n", "i", "v" }, desc = "Open messages log" },
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
                    cmdline = { pattern = "^:", icon = "❯", lang = "vim" },
                    search_down = { view = "cmdline", icon = "  " },
                    search_up = { view = "cmdline", icon = "  " },
                },
            },

            notify = {
                enabled = false,
            },

            lsp = {
                hover = {
                    enabled = false,
                },
                signature = {
                    enabled = true,
                    view = "hint",
                },
            },

            status = {
                lsp_progress = {
                    event = "lsp",
                    kind = "progress",
                },
            },

            commands = {
                all = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter_opts = { reverse = true },
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
                        width = NVLayout.default_width(),
                        height = NVScreen.is_large() and 30 or 15,
                    },
                    win_options = Layout.common.win_options,
                    close = {
                        events = { "BufLeave" },
                        keys = { NVKeymaps.close },
                    },
                },
                hint = {
                    backend = "popup",
                    relative = "cursor",
                    size = {
                        width = "auto",
                        height = "auto",
                        max_height = 20,
                        max_width = 120,
                    },
                    position = { row = Layout.common.border.padding.top + 1, col = 0 },
                    border = Layout.common.border,
                    win_options = {
                        wrap = true,
                        linebreak = true,
                    },
                    close = {
                        keys = { NVKeymaps.close },
                    },
                },
                cmdline = {
                    position = {
                        row = vim.o.lines,
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
                confirm = {
                    backend = "popup",
                    relative = "editor",
                    focusable = false,
                    align = "center",
                    enter = false,
                    zindex = 210,
                    format = { "{confirm}" },
                    position = {
                        row = 3,
                        col = "50%",
                    },
                    size = "auto",
                    border = {
                        style = Layout.common.border.style,
                        padding = Layout.common.border.padding,
                        text = {
                            top = " Confirm ",
                        },
                    },
                    win_options = Layout.common.win_options,
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
    end,
}

---@param direction "up"|"down"
function NVNoice.scroll_lsp_doc(direction)
    local plugin = require("noice.lsp")

    if direction == "up" then
        return plugin.scroll(-4)
    elseif direction == "down" then
        return plugin.scroll(4)
    else
        return false
    end
end

function NVNoice.ensure_hidden()
    if fn.ensure_command_line_hidden() then
        return true
    end

    if fn.ensure_signature_hidden() then
        return true
    end

    local current_win = vim.api.nvim_get_current_win()

    if fn.is_win_active() then
        if NVWindows.is_window_floating(current_win) then
            fn.close_split()
            return true
        else
            -- Probably, needs specal handling of general window depending on the layout
            fn.close_split()
            return true
        end
    else
        return false
    end
end

function fn.is_win_active()
    return vim.bo.filetype == "noice"
end

function fn.close_split()
    vim.cmd.close()
end

---@return boolean
function fn.ensure_command_line_hidden()
    local mode = vim.fn.mode()

    if mode == "c" then
        NVKeys.send("<Esc>", { mode = "n" })
        return true
    end

    return false
end

---@return boolean
function fn.ensure_signature_hidden()
    local lsp = require("noice.lsp")
    local docs = require("noice.lsp.docs")

    local signature = docs.get(lsp.kinds.signature)

    if #signature:wins() == 0 then
        return false
    end

    docs.hide(signature)

    return true
end

return { NVNoice }
