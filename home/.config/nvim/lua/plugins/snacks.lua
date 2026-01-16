NVSPickers = {}
NVSZoom = {}
NVSLazygit = {}
NVSTerminal = {}
NVSNotifier = {}

NVSPickerVerticalLayout = {
    large_screen_width = 0.4,
    small_screen_width = 0.5,
}
NVSPickerHorizontalLayout = {
    large_screen_width = 0.75,
    small_screen_width = 0.95,
}

function NVSPickerVerticalLayout.build(opts)
    local config = vim.tbl_extend("keep", opts or {}, {
        width = NVScreen.is_large() and NVSPickerVerticalLayout.large_screen_width
            or NVSPickerVerticalLayout.small_screen_width,
        height = 0.7,
    })

    return {
        layout = {
            box = "vertical",
            width = config.width,
            height = config.height,
            border = "none",
            backdrop = false,
            {
                win = "input",
                height = 1,
                title = "{title} {live}",
                title_pos = "center",
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
            {
                win = "list",
                border = { "", "", "", " ", "", "", "", " " },
            },
            {
                win = "preview",
                title = "{preview}",
                border = { " ", "─", " ", " ", " ", " ", " ", " " },
            },
        },
    }
end

function NVSPickerHorizontalLayout.build(opts)
    local config = vim.tbl_extend("keep", opts or {}, {
        width = NVScreen.is_large() and NVSPickerHorizontalLayout.large_screen_width
            or NVSPickerHorizontalLayout.small_screen_width,
        height = 0.9,
    })

    return {
        layout = {
            box = "horizontal",
            width = config.width,
            height = config.height,
            backdrop = false,
            {
                box = "vertical",
                {
                    win = "input",
                    height = 1,
                    title = "{title} {live}",
                    title_pos = "center",
                    border = { " ", " ", " ", " ", " ", " ", " ", " " },
                },
                {
                    win = "list",
                    border = { "", "", "", " ", " ", " ", " ", " " },
                },
            },
            {
                win = "preview",
                title = "{preview}",
                border = { "", " ", " ", " ", " ", " ", "", "" },
            },
        },
    }
end

NVSPickers.keys = {
    ["<D-S-m>"] = { "toggle_maximize", mode = { "n", "i", "v" } },
    [NVKeymaps.open_vsplit] = { "edit_vsplit", mode = { "n", "i", "v" } },
    [NVKeymaps.open_hsplit] = { "edit_split", mode = { "n", "i", "v" } },
    ["<C-Tab>"] = { "cycle_win", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll.up] = { "list_scroll_up", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll.down] = { "list_scroll_down", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll_alt.up] = { "x_list_scroll_up_bit", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll_alt.down] = { "x_list_scroll_down_bit", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll_ctx.up] = { "preview_scroll_up", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll_ctx.down] = { "preview_scroll_down", mode = { "n", "i", "v" } },
    ["<C-l>"] = { "focus_list", mode = { "n", "i", "v" } },
    ["<C-i>"] = { "focus_input", mode = { "n", "i", "v" } },
    ["<C-p>"] = { "focus_preview", mode = { "n", "i", "v" } },
    ["<D-S-p>"] = { "toggle_preview", mode = { "n", "i", "v" } },
    ["<D-S-a>"] = { "x_copy_absolute_path", mode = { "n", "i", "v" } },
    ["<D-S-r>"] = { "x_copy_relative_path", mode = { "n", "i", "v" } },
    ["<D-S-n>"] = { "x_copy_filename", mode = { "n", "i", "v" } },
    ["<D-S-s>"] = { "x_copy_filestem", mode = { "n", "i", "v" } },
    [NVKeymaps.close] = { "close", mode = { "n", "i", "v" } },
}

NVSPickers.actions = {
    x_list_scroll_up_bit = function(picker)
        picker.list:scroll(-2)
    end,
    x_list_scroll_down_bit = function(picker)
        picker.list:scroll(2)
    end,
    x_copy_absolute_path = function(_, item)
        NVSPickers.copy_path(item, "absolute")
    end,
    x_copy_relative_path = function(_, item)
        NVSPickers.copy_path(item, "relative")
    end,
    x_copy_filename = function(_, item)
        NVSPickers.copy_path(item, "filename")
    end,
    x_copy_filestem = function(_, item)
        NVSPickers.copy_path(item, "filestem")
    end,
}

---@param item snacks.picker.explorer.Item
---@param fmt "absolute" | "relative" | "filename" | "filestem"
function NVSPickers.copy_path(item, fmt)
    if item == nil then
        log.info("No item selected")
        return
    end

    local result = NVFS.format(item.file, fmt)

    if result ~= nil then
        NVClipboard.yank(result)
        log.info("Copied: " .. result)
    else
        log.error("Failed to copy")
    end
end

NVSnacks = {
    "folke/snacks.nvim",
    event = "VeryLazy",
    keys = function()
        return {
            { "<D-t>", NVSPickers.files, mode = { "n", "i", "v", "t" }, desc = "Open file finder" },
            { "<D-b>", NVSPickers.buffers, mode = { "n", "i", "v", "t" }, desc = "Open buffers list" },
            { "<D-g>b", NVSPickers.git_branches, mode = { "n", "i", "v", "t" }, desc = "Git: Branches" },
            { "<M-f>", NVSPickers.text_search, mode = { "n", "i", "v", "t" }, desc = "Open text search" },
            { "<M-h>", NVSPickers.highlights, mode = "n", desc = "Show highlights" },
            { "<D-g>g", NVSLazygit.show, mode = { "n", "i", "v", "t" }, desc = "Git: Lazygit" },
            { "<D-S-m>", NVSZoom.activate, mode = { "n", "i", "v" }, desc = "Maximize" },
            { "<D-l>", NVSNotifier.log, mode = { "n", "i", "v" }, desc = "Open log" },
        }
    end,
    opts = {
        dashboard = { enabled = false },
        input = {
            enabled = true,
            backdrop = false,
            keys = {
                [NVKeymaps.close] = "cancel",
            },
        },
        statuscolumn = {
            enabled = true,
        },
        explorer = {
            tree = false,
            replace_netrw = true,
        },
        picker = {
            enabled = true,
            prompt = "❯ ",
            ui_select = true,
            layout = NVSPickerVerticalLayout.build(),
            win = {
                input = { keys = NVSPickers.keys },
                list = { keys = NVSPickers.keys },
                preview = { keys = NVSPickers.keys },
            },
            formatters = {
                file = {
                    filename_first = true,
                },
            },
            icons = {
                diagnostics = {
                    Error = NVIcons.error,
                    Warn = NVIcons.warn,
                    Hint = NVIcons.hint,
                    Info = NVIcons.info,
                },
                tree = {
                    vertical = "│   ",
                    middle = "│   ",
                    last = "└── ",
                },
            },
            actions = NVSPickers.actions,
        },
        notifier = {
            enabled = true,
            timeout = 3000,
            level = vim.log.levels.DEBUG,
            margin = { top = 1, right = 1, bottom = 0 },
            icons = {
                error = NVIcons.error,
                warn = NVIcons.warn,
                info = NVIcons.info,
                debug = NVIcons.debug,
            },
            filter = function(n)
                local tab_name = vim.fn.gettabvar(vim.fn.tabpagenr(), "tabname")
                if tab_name == NVDiffview.tab_name then
                    if
                        string.find(n.msg, "^Client %S+ quit with exit code %d+ and signal %d+%.")
                        or string.find(n.msg, "^%[null%-ls%] failed to run generator")
                    then
                        return false
                    else
                        return true
                    end
                else
                    return true
                end
            end,
        },
        indent = {
            enabled = true,
            indent = {
                enabled = true,
                only_scope = false,
                only_current = false,
                hl = "SnacksIndent",
            },
            scope = {
                enabled = true,
                hl = "SnacksIndentScope",
            },
            chunk = {
                enabled = true,
            },
        },
        lazygit = {
            configure = true,
        },
        zen = {
            zoom = {
                show = {
                    statusline = true,
                    tabline = true,
                },
                win = {
                    width = 0,
                    backdrop = false,
                },
            },
        },
        styles = {
            lazygit = {
                backdrop = false,
            },
            zoom_indicator = {
                text = "▍   zoom    󰊓  ",
            },
            terminal = {
                wo = {
                    winhighlight = "Normal:SnacksTerminal,WinBar:SnacksTerminalHeader,WinBarNC:SnacksTerminalHeaderNC",
                },
            },
            notification = {
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
            notification_history = {
                backdrop = false,
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
                keys = {
                    q = "close",
                    [NVKeymaps.close] = "close",
                },
            },
        },
    },
}

function NVSPickers.files()
    Snacks.picker.files({
        show_empty = true,
        hidden = true,
        ignored = false,
        follow = false,
        supports_live = true,
        layout = NVSPickerVerticalLayout.build(),
    })
end

function NVSPickers.buffers()
    Snacks.picker.buffers({
        hidden = true,
        unloaded = true,
        current = false,
        sort_lastused = true,
        layout = NVSPickerVerticalLayout.build(),
        filter = {
            filter = function(item, _)
                if string.find(item.file, "^diffview://") then
                    return false
                elseif string.find(item.file, "^term://") then
                    return false
                elseif string.find(item.file, "^oil://") then
                    return false
                else
                    return true
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ["<D-BS>"] = { "bufdelete", mode = { "n", "i" } },
                },
            },
            list = {
                keys = {
                    ["dd"] = "bufdelete",
                },
            },
        },
    })
end

function NVSPickers.text_search()
    Snacks.picker.grep({
        hidden = true,
        ignored = false,
        regex = false,
        layout = NVSPickerHorizontalLayout.build(),
    })
end

function NVSPickers.git_branches()
    Snacks.picker.git_branches({
        layout = NVSPickerVerticalLayout.build(),
        win = {
            input = {
                keys = {
                    ["<D-n>"] = { "git_branch_add", mode = { "n", "i" } },
                    ["<D-x>"] = { "git_branch_del", mode = { "n", "i" } },
                },
            },
        },
    })
end

function NVSPickers.lsp_document_symbols()
    Snacks.picker.lsp_symbols({
        layout = NVSPickerVerticalLayout.build({
            width = NVScreen.is_large() and 0.5 or 0.8,
            height = 0.9,
        }),
    })
end

function NVSPickers.lsp_workspace_symbols()
    Snacks.picker.lsp_workspace_symbols({
        layout = NVSPickerVerticalLayout.build({
            width = NVScreen.is_large() and 0.5 or 0.8,
            height = 0.9,
        }),
    })
end

function NVSPickers.lsp_references()
    Snacks.picker.lsp_references({
        auto_confirm = false,
        layout = NVSPickerHorizontalLayout.build(),
    })
end

function NVSPickers.lsp_implementations()
    Snacks.picker.lsp_implementations({
        auto_confirm = false,
        layout = NVSPickerHorizontalLayout.build(),
    })
end

function NVSPickers.lsp_definitions()
    Snacks.picker.lsp_definitions({
        auto_confirm = true,
        layout = NVSPickerVerticalLayout.build(),
    })
end

function NVSPickers.lsp_type_definitions()
    Snacks.picker.lsp_type_definitions({
        auto_confirm = true,
        layout = NVSPickerVerticalLayout.build(),
    })
end

function NVSPickers.lsp_declarations()
    Snacks.picker.lsp_declarations({
        auto_confirm = true,
        layout = NVSPickerVerticalLayout.build(),
    })
end

function NVSPickers.highlights()
    Snacks.picker.highlights({
        layout = NVSPickerHorizontalLayout.build(),
        win = {
            input = {
                keys = {
                    ["<CR>"] = { "x_copy_highlight", mode = { "n", "i" } },
                },
            },
        },
        actions = {
            x_copy_highlight = function(picker, item)
                if item.hl_group then
                    NVClipboard.yank(item.hl_group)
                    log.info("Copied: " .. item.hl_group)
                    picker:close()
                end
            end,
        },
    })
end

function NVSZoom.activate()
    Snacks.zen.zoom()
end

---@return boolean
function NVSZoom.ensure_deactivated()
    local win = Snacks.zen.win
    if win then
        Snacks.zen.zoom()
        return true
    end
    return false
end

---@param app string
---@param bufid BufID | nil
---@return boolean
function NVSTerminal.is_app(app, bufid)
    bufid = bufid or vim.api.nvim_get_current_buf()

    local buf_info = vim.fn.getbufinfo(bufid)[1]

    if buf_info and buf_info.variables.snacks_terminal and buf_info.variables.snacks_terminal.cmd then
        local cmd = buf_info.variables.snacks_terminal.cmd

        if type(cmd) == "string" then
            return string.find(cmd, app) ~= nil
        elseif type(cmd) == "table" and cmd[1] then
            return string.find(cmd[1], app) ~= nil
        else
            return false
        end
    else
        return false
    end
end

function NVSNotifier.log()
    Snacks.notifier.show_history()
end

function NVSNotifier.hide()
    Snacks.notifier.hide()
end

function NVSLazygit.show()
    Snacks.lazygit()
end

---@return boolean
function NVSLazygit.ensure_hidden()
    if NVSTerminal.is_app("lazygit") then
        Snacks.lazygit()
        return true
    end
    return false
end

return { NVSnacks }
