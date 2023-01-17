local plugin = require "cmp"

local mapping = plugin.mapping

plugin.setup {
    sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "buffer" },
        { name = "path" },
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = mapping.preset.insert({
        ["<C-k>"] = mapping.scroll_docs(-4),
        ["<C-j>"] = mapping.scroll_docs(4),
        ["<C-Space>"] = mapping.complete(),
        ["<C-e>"] = mapping.abort(),
        ["<Tab>"] = mapping(
            function(fallback)
                if plugin.visible() then
                    plugin.select_next_item()
                elseif require("luasnip").expand_or_jumpable() then
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                else
                    fallback()
                end
            end,
            { "i", "s" }
        ),
        ["<S-Tab>"] = mapping(
            function(fallback)
                if plugin.visible() then
                    plugin.select_prev_item()
                elseif require("luasnip").jumpable(-1) then
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
                else
                    fallback()
                end
            end,
            { "i", "s" }
        ),
        ["<CR>"] = mapping.confirm({
            behavior = plugin.ConfirmBehavior.Insert,
            select = true,
        }),
    }),
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
            col_offset = -3,
            side_padding = 0,
        },
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
                },
                maxwidth = 50,
            })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. strings[1] .. " "
            kind.menu = "    [" .. kind.menu .. ": " .. strings[2] .. "]"
            return kind
        end,
    },
}

-- autopairs :shake_hands:
local autopairs = require "nvim-autopairs.completion.cmp"

plugin.event:on("confirm_done", autopairs.on_confirm_done())
