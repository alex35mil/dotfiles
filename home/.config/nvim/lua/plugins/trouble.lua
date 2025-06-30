local fn = {}
local win = {}

NVTrouble = {
    "folke/trouble.nvim",
    keys = function()
        return {
            {
                "<A-S-e>",
                function()
                    fn.open_diagnosics({ severity = vim.diagnostic.severity.ERROR })
                end,
                mode = { "n", "i", "v" },
                desc = "Diagnostics: ERROR [workspace]",
            },
            {
                "<C-S-e>",
                function()
                    fn.open_diagnosics({ buf = 0, severity = vim.diagnostic.severity.ERROR })
                end,
                mode = { "n", "i", "v" },
                desc = "Diagnostics: ERROR [current buffer]",
            },
            {
                "<A-S-w>",
                function()
                    fn.open_diagnosics({ severity = vim.diagnostic.severity.WARN })
                end,
                mode = { "n", "i", "v" },
                desc = "Diagnostics: WARN [workspace]",
            },
            {
                "<C-S-w>",
                function()
                    fn.open_diagnosics({ buf = 0, severity = vim.diagnostic.severity.WARN })
                end,
                mode = { "n", "i", "v" },
                desc = "Diagnostics: WARN [current buffer]",
            },
        }
    end,
    opts = function()
        return {
            auto_close = false, -- auto close when there are no items
            auto_open = false, -- auto open when there are items
            auto_preview = true, -- automatically open preview when on an item
            auto_refresh = true, -- auto refresh when open
            auto_jump = false, -- auto jump to the item when there's only one
            focus = true, -- Focus the window when opened
            restore = true, -- restores the last location in the list when opening
            follow = false, -- Follow the current item
            indent_guides = false, -- show indent guides
            max_items = 200, -- limit number of items that can be displayed per section
            multiline = true, -- render multi-line messages
            pinned = false, -- When pinned, the opened trouble window will be bound to the current buffer
            warn_no_results = true, -- show a warning when there are no results
            open_no_results = false, -- open the trouble window when there are no results
            keys = {
                [NVKeymaps.close] = "close",
                ["<CR>"] = "jump_close",
                ["<cr>"] = "jump_close",
                ["<Right>"] = "fold_open",
                ["<D-Right>"] = "fold_open_recursive",
                ["<Left>"] = "fold_close",
                ["<D-Left>"] = "fold_close_recursive",
                ["<Space>"] = "fold_toggle",
                ["<D-Space>"] = "fold_toggle_recursive",
                ["<D-S-CR>"] = "jump_split_close",
                ["<D-CR>"] = "jump_vsplit_close",
            },
        }
    end,
}

function win.float(opts)
    local base = {
        type = "float",
        relative = "editor",
        title_pos = "center",
        border = "solid",
        zindex = 1000,
    }

    return vim.tbl_extend("error", base, opts)
end

function fn.open_diagnosics(filter)
    local trouble = require("trouble")

    local size = {
        width = NVScreen.is_large() and NVWindows.default_width() or 0.8,
        height = 0.4,
    }

    local shift = 0.4

    trouble.open({
        mode = "diagnostics",
        focus = true,
        filter = filter,
        win = win.float({
            title = " Diagnostics ",
            size = size,
            position = { 0.5 - shift, 0.5 },
        }),
        preview = win.float({
            title = " Preview ",
            size = size,
            position = { 0.5 + shift - 0.05, 0.5 },
            scratch = true,
        }),
    })
end

function fn.open_symbol_usage()
    local trouble = require("trouble")

    local large_screen = NVScreen.is_large()

    local size = {
        width = large_screen and 100 or 0.45,
        height = 0.8,
    }

    local shift = large_screen and 0.35 or 0.42

    trouble.open({
        mode = "lsp",
        focus = true,
        win = win.float({
            title = " LSP ",
            size = size,
            position = { 0.5, 0.5 - shift },
        }),
        preview = win.float({
            title = " Preview ",
            size = size,
            position = { 0.5, 0.5 + shift },
            scratch = true,
        }),
    })
end

function fn.open_symbols()
    local trouble = require("trouble")

    local large_screen = NVScreen.is_large()

    trouble.open({
        mode = "symbols",
        focus = true,
        win = win.float({
            title = " Document Symbols ",
            size = {
                width = 100,
                height = 0.45,
            },
            position = { large_screen and 0.3 or 0.4, 0.5 },
        }),
    })
end

function NVTrouble.ensure_hidden()
    local trouble = require("trouble")

    if trouble.is_open() then
        trouble.close()
        return true
    else
        return false
    end
end

return { NVTrouble }
