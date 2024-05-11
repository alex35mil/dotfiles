local M = {}

function M.setup()
    local plugin = require "cmp"

    local mapping = plugin.mapping

    local bordered_window = plugin.config.window.bordered({
        winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        col_offset = -3,
        side_padding = 0,
    })

    plugin.setup {
        sources = {
            { name = "luasnip" },
            { name = "nvim_lsp" },
            { name = "nvim_lua" },
            { name = "buffer" },
            { name = "path" },
            { name = "crates" },
        },
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        mapping = mapping.preset.insert({
            ["<D-Up>"] = mapping.scroll_docs(-4),
            ["<D-Down>"] = mapping.scroll_docs(4),
            ["<C-c>"] = mapping.complete(),
            ["<D-w>"] = mapping.abort(),
            ["<CR>"] = mapping.confirm({
                behavior = plugin.ConfirmBehavior.Insert,
                select = true,
            }),
        }),
        window = {
            completion = bordered_window,
            documentation = bordered_window,
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                local kind = require("lspkind").cmp_format({
                    mode = "symbol_text",
                    menu = {
                        luasnip = "Snip",
                        nvim_lua = "Lua",
                        nvim_lsp = "LSP",
                        buffer = "Buf",
                        path = "Path",
                        crates = "Crates",
                    },
                    maxwidth = 50,
                })(entry, vim_item)
                local strings = vim.split(kind.kind, "%s", { trimempty = true })
                kind.kind = " " .. strings[1] .. " "
                if strings[2] then
                    kind.menu = "    [" .. kind.menu .. ": " .. strings[2] .. "]"
                else
                    kind.menu = "    [" .. kind.menu .. "]"
                end
                return kind
            end,
        },
    }

    -- autopairs :shake_hands:
    local autopairs = require "nvim-autopairs.completion.cmp"

    plugin.event:on("confirm_done", autopairs.on_confirm_done())
end

return M
