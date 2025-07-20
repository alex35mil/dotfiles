NVTreeSitter = {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    event = "VeryLazy",
    lazy = vim.fn.argc(-1) == 0,
    keys = function()
        local ts = require("nvim-treesitter.textobjects.repeatable_move")

        return {
            { ";", ".", mode = { "n", "x", "o" }, desc = "Repeat" },
            { ".", ts.repeat_last_move_next, mode = { "n", "x", "o" }, desc = "Repeat last move forward" },
            { ",", ts.repeat_last_move_previous, mode = { "n", "x", "o" }, desc = "Repeat last move backward" },
            { "f", ts.builtin_f_expr, mode = { "n", "x", "o" }, desc = "Repeat last move f", expr = true },
            { "F", ts.builtin_F_expr, mode = { "n", "x", "o" }, desc = "Repeat last move F", expr = true },
            { "t", ts.builtin_t_expr, mode = { "n", "x", "o" }, desc = "Repeat last move t", expr = true },
            { "T", ts.builtin_T_expr, mode = { "n", "x", "o" }, desc = "Repeat last move T", expr = true },
        }
    end,
    opts = {
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
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
                },
                selection_modes = {
                    ["@class.outer"] = "V", -- linewise
                    ["@function.outer"] = "V", -- linewise
                },
                include_surrounding_whitespace = false,
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next = {
                    ["]f"] = "@function.outer",
                    ["]c"] = "@class.outer",
                    ["]b"] = "@block.outer",
                    ["]i"] = "@conditional.outer",
                    ["]l"] = "@loop.outer",
                    ["]xa"] = "@call.outer",
                    ["]xi"] = "@call.inner",
                },
                goto_previous = {
                    ["[f"] = "@function.outer",
                    ["[c"] = "@class.outer",
                    ["[b"] = "@block.outer",
                    ["[i"] = "@conditional.outer",
                    ["[l"] = "@loop.outer",
                    ["[xa"] = "@call.outer",
                    ["[xi"] = "@call.inner",
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<Leader>a"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<Leader>A"] = "@parameter.inner",
                },
            },
        },
    },
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}

return { NVTreeSitter }
