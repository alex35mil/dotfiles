NVSPickers = {}
NVSZoom = {}
NVSLazygit = {}
NVSTerminal = {}

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
    [NVKeyRemaps["<D-m>"]] = { "toggle_maximize", mode = { "n", "i", "v" } },
    ["<D-CR>"] = { "edit_vsplit", mode = { "n", "i", "v" } },
    ["<D-S-CR>"] = { "edit_split", mode = { "n", "i", "v" } },
    ["<C-Tab>"] = { "cycle_win", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll.up] = { "preview_scroll_up", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll.down] = { "preview_scroll_down", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll_alt.up] = { "list_scroll_up", mode = { "n", "i", "v" } },
    [NVKeymaps.scroll_alt.down] = { "list_scroll_down", mode = { "n", "i", "v" } },
    [NVKeymaps.close] = { "close", mode = { "n", "i", "v" } },
}

NVSnacks = {
    "folke/snacks.nvim",
    event = "VeryLazy",
    keys = function()
        return {
            { "<D-S-e>", NVSPickers.explorer, mode = { "n", "i", "v" }, desc = "Open file tree" },
            { "<D-t>", NVSPickers.files, mode = { "n", "i", "v" }, desc = "Open file finder" },
            { "<D-b>", NVSPickers.buffers, mode = { "n", "i", "v" }, desc = "Open buffers list" },
            { "<M-f>", NVSPickers.text_search, mode = { "n", "i", "v" }, desc = "Open text search" },
            { "<D-g>b", NVSPickers.git_branches, mode = { "n", "i", "v" }, desc = "Git: Branches" },
            { "<Leader>h", NVSPickers.highlights, mode = "n", desc = "Show highlights" },
            { "<D-g>g", NVSLazygit.show, mode = { "n", "i", "v" }, desc = "Git: Lazygit" },
            { "<D-S-m>", NVSZoom.activate, mode = { "n", "i", "v" }, desc = "Maximize" },
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
        },
    },
}

function NVSPickers.explorer()
    local layout = NVSPickerHorizontalLayout.build()

    Snacks.picker.explorer({
        hidden = true,
        ignored = true,
        jump = { close = true },
        layout = {
            preview = true,
            layout = layout.layout,
        },
        win = {
            list = {
                keys = {
                    [NVKeymaps.close] = { "close", mode = { "n", "i", "v" } },
                },
            },
        },
    })
end

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
            filter = function(item, filter)
                if string.find(item.file, "^diffview://") then
                    return false
                elseif string.find(item.file, "^term://") then
                    return false
                else
                    return true
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ["<D-x>"] = { "bufdelete", mode = { "n", "i" } },
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
