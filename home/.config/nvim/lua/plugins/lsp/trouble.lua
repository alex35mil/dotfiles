local fn = {}

local DIAGNOSTICS_SOURCE = "diagnostics_per_ft"

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
                ["<S-CR>"] = "jump",
                ["<D-S-CR>"] = "jump_split_close",
                ["<D-CR>"] = "jump_vsplit_close",
                ["<Right>"] = "fold_open",
                ["<D-Right>"] = "fold_open_recursive",
                ["<Left>"] = "fold_close",
                ["<D-Left>"] = "fold_close_recursive",
                ["<Space>"] = "fold_toggle",
                ["<D-Space>"] = "fold_toggle_recursive",
            },
        }
    end,
    config = function(_, opts)
        require("trouble").setup(opts)
        require("trouble.sources").register(DIAGNOSTICS_SOURCE, {
            get = function(cb)
                local Item = require("trouble.item")

                local items = {}
                local clients = vim.lsp.get_clients({ bufnr = 0 })

                for _, client in ipairs(clients) do
                    local ns = vim.lsp.diagnostic.get_namespace(client.id)
                    local diags = vim.diagnostic.get(nil, { namespace = ns })

                    for _, d in ipairs(diags) do
                        table.insert(
                            items,
                            Item.new({
                                source = "diagnostics",
                                buf = d.bufnr,
                                pos = { d.lnum + 1, d.col },
                                end_pos = { d.end_lnum and (d.end_lnum + 1) or nil, d.end_col },
                                item = d,
                            })
                        )
                    end
                end

                cb(items)
            end,
            config = {
                format = "{severity_icon} {message:md} {item.source} {code} {pos}",
                groups = {
                    { "directory" },
                    { "filename", format = "{file_icon} {basename} {count}" },
                },
                modes = {
                    [DIAGNOSTICS_SOURCE] = {
                        source = DIAGNOSTICS_SOURCE,
                    },
                },
            },
        })
    end,
}

local win = {
    size = 0.4,
    position = "bottom",
}

function fn.open_diagnosics(filter)
    local trouble = require("trouble")

    trouble.open({
        mode = DIAGNOSTICS_SOURCE,
        focus = true,
        filter = filter,
        win = win,
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
