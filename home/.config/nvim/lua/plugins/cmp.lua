NVCmp = {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
        local cmp = require("cmp")

        local mapping = cmp.mapping

        opts.mapping = mapping.preset.insert({
            [NVKeymaps.scroll.up] = mapping.scroll_docs(-4),
            [NVKeymaps.scroll.down] = mapping.scroll_docs(4),
            ["<C-c>"] = mapping.complete(),
            ["<CR>"] = LazyVim.cmp.confirm({ select = true }),
            [NVKeymaps.close] = mapping.abort(),
        })

        -- Don't trigger completion on {
        opts.completion = vim.tbl_extend("force", opts.completion or {}, {
            keyword_length = 2,
        })

        -- Prioritize `crates` source
        opts.sources = vim.tbl_filter(function(source)
            return not vim.tbl_contains({ "crates" }, source.name)
        end, opts.sources)

        table.insert(opts.sources, 1, {
            name = "crates",
            priority = 1000,
            group_index = 0,
        })

        return opts
    end,
}

return { NVCmp }
