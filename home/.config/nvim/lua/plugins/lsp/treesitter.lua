NVTreeSitter = {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = "VeryLazy",
    lazy = vim.fn.argc(-1) == 0,
    opts = {},
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
        if opts.ensure_installed then
            require("nvim-treesitter").install(opts.ensure_installed)
        end

        -- Auto-start treesitter highlight/indent for non-bundled parsers
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                if vim.b[args.buf].ts_highlight then
                    return
                end
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if lang and vim.treesitter.language.add(lang) then
                    vim.treesitter.start(args.buf, lang)
                end
            end,
        })
    end,
}

NVTreeSitterTextobjects = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    config = function()
        local ts_select = require("nvim-treesitter-textobjects.select")
        local ts_move = require("nvim-treesitter-textobjects.move")
        local ts_swap = require("nvim-treesitter-textobjects.swap")
        local ts_repeat = require("nvim-treesitter-textobjects.repeatable_move")

        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,
                selection_modes = {
                    ["@class.outer"] = "V",
                    ["@function.outer"] = "V",
                },
                include_surrounding_whitespace = false,
            },
            move = {
                set_jumps = true,
            },
        })

        -- Select keymaps
        local select_keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ax"] = "@call.outer",
            ["ix"] = "@call.inner",
        }
        for key, query in pairs(select_keymaps) do
            vim.keymap.set({ "x", "o" }, key, function()
                ts_select.select_textobject(query)
            end, { desc = "Select " .. query })
        end

        -- Move keymaps
        local move_next = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]b"] = "@block.outer",
            ["]i"] = "@conditional.outer",
            ["]l"] = "@loop.outer",
            ["]xa"] = "@call.outer",
            ["]xi"] = "@call.inner",
        }
        local move_prev = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[b"] = "@block.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
            ["[xa"] = "@call.outer",
            ["[xi"] = "@call.inner",
        }
        for key, query in pairs(move_next) do
            vim.keymap.set({ "n", "x", "o" }, key, function()
                ts_move.goto_next_start(query)
            end, { desc = "Next " .. query })
        end
        for key, query in pairs(move_prev) do
            vim.keymap.set({ "n", "x", "o" }, key, function()
                ts_move.goto_previous_start(query)
            end, { desc = "Prev " .. query })
        end

        -- Swap keymaps
        vim.keymap.set("n", "<Leader>a", function()
            ts_swap.swap_next("@parameter.inner")
        end, { desc = "Swap next parameter" })
        vim.keymap.set("n", "<Leader>A", function()
            ts_swap.swap_previous("@parameter.inner")
        end, { desc = "Swap prev parameter" })

        -- Repeatable move keymaps
        vim.keymap.set({ "n", "x", "o" }, ";", ".", { desc = "Repeat" })
        vim.keymap.set({ "n", "x", "o" }, ".", ts_repeat.repeat_last_move_next, { desc = "Repeat last move forward" })
        vim.keymap.set(
            { "n", "x", "o" },
            ",",
            ts_repeat.repeat_last_move_previous,
            { desc = "Repeat last move backward" }
        )
        vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true, desc = "Repeat f" })
        vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true, desc = "Repeat F" })
        vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true, desc = "Repeat t" })
        vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true, desc = "Repeat T" })
    end,
}

return { NVTreeSitter, NVTreeSitterTextobjects }
