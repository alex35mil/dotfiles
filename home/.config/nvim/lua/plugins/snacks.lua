NVSPickers = {}
NVSZoom = {}
NVSLazygit = {}

local SnacksVerticalLayout = {}
local SnacksHorizontalLayout = {}

SnacksVerticalLayout = {
    large_screen_width = 0.4,
    small_screen_width = 0.5,
}

function SnacksVerticalLayout.build(opts)
    local config = vim.tbl_extend("keep", opts or {}, {
        width = NVScreen.is_large() and SnacksVerticalLayout.large_screen_width or SnacksVerticalLayout.small_screen_width,
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

SnacksHorizontalLayout = {
    large_screen_width = 0.75,
    small_screen_width = 0.95,
}

function SnacksHorizontalLayout.build(opts)
    local config = vim.tbl_extend("keep", opts or {}, {
        width = NVScreen.is_large() and SnacksHorizontalLayout.large_screen_width or SnacksHorizontalLayout.small_screen_width,
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
    keys = function()
        return {
            { "<D-S-e>", NVSPickers.explorer, mode = { "n", "i", "v" }, desc = "Open file tree" },
            { "<D-t>", NVSPickers.files, mode = { "n", "i", "v" }, desc = "Open file finder" },
            { "<D-b>", NVSPickers.buffers, mode = { "n", "i", "v" }, desc = "Open buffers list" },
            { "<M-f>", NVSPickers.text_search, mode = { "n", "i", "v" }, desc = "Open text search" },
            { "<D-o>", NVSPickers.lsp_document_symbols, mode = { "n", "i", "v" }, desc = "LSP: Open document symbols" },
            { "<D-S-o>", NVSPickers.lsp_workspace_symbols, mode = { "n", "i", "v" }, desc = "LSP: Open workspace symbols" },
            { "<D-u>", NVSPickers.lsp_references, mode = { "n", "i", "v" }, desc = "Open symbol usage" },
            { "<D-S-i>", NVSPickers.lsp_implementations, mode = { "n", "i", "v" }, desc = "Open symbol usage" },
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
        explorer = {
            tree = false,
            replace_netrw = true,
        },
        picker = {
            enabled = true,
            prompt = "❯ ",
            ui_select = true,
            layout = SnacksVerticalLayout.build(),
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
        },
    },
}

function NVSPickers.explorer()
    local layout = SnacksHorizontalLayout.build()

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
        layout = SnacksVerticalLayout.build(),
    })
end

function NVSPickers.buffers()
    Snacks.picker.buffers({
        hidden = true,
        unloaded = true,
        current = false,
        sort_lastused = true,
        layout = SnacksVerticalLayout.build(),
        filter = {
            filter = function(item, filter)
                if item.file == "diffview://null" then
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
        layout = SnacksHorizontalLayout.build(),
    })
end

function NVSPickers.git_branches()
    Snacks.picker.git_branches({
        layout = SnacksVerticalLayout.build(),
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
        layout = SnacksVerticalLayout.build({
            width = NVScreen.is_large() and 0.5 or 0.8,
            height = 0.9,
        }),
    })
end

function NVSPickers.lsp_workspace_symbols()
    Snacks.picker.lsp_workspace_symbols({
        layout = SnacksVerticalLayout.build({
            width = NVScreen.is_large() and 0.5 or 0.8,
            height = 0.9,
        }),
    })
end

function NVSPickers.lsp_references()
    Snacks.picker.lsp_references({
        auto_confirm = false,
        layout = SnacksHorizontalLayout.build(),
    })
end

function NVSPickers.lsp_implementations()
    Snacks.picker.lsp_implementations({
        auto_confirm = false,
        layout = SnacksHorizontalLayout.build(),
    })
end

function NVSPickers.lsp_definitions()
    Snacks.picker.lsp_definitions({
        auto_confirm = true,
        layout = SnacksVerticalLayout.build(),
    })
end

function NVSPickers.lsp_type_definitions()
    Snacks.picker.lsp_type_definitions({
        auto_confirm = true,
        layout = SnacksVerticalLayout.build(),
    })
end

function NVSPickers.lsp_declarations()
    Snacks.picker.lsp_declarations({
        auto_confirm = true,
        layout = SnacksVerticalLayout.build(),
    })
end

function NVSPickers.highlights()
    Snacks.picker.highlights({
        layout = SnacksHorizontalLayout.build(),
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

function NVSLazygit.show()
    Snacks.lazygit()
end

---@return boolean
function NVSLazygit.ensure_hidden()
    if vim.bo.filetype == "snacks_terminal" then
        vim.cmd.close()
        return true
    end
    return false
end

return { NVSnacks }
