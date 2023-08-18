local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local lazy = require "lazy"

local plugins = {
    -- stdlib
    {
        "nvim-lua/plenary.nvim",
        version = "*",
    },

    -- theming
    {
        "rktjmp/lush.nvim",
        branch = "main",
        lazy = false,
    },

    -- keymaps
    {
        "folke/which-key.nvim",
        version = "*",
        config = function() require "plugins/which-key" end,
    },

    -- essentials
    {
        "echasnovski/mini.trailspace",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/mini-trailspace" end,
    },

    {
        "rlane/pounce.nvim",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/pounce" end,
    },

    {
        "xiyaowong/virtcolumn.nvim",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/virtcolumn" end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        version = "*",
        config = function() require "plugins/indent-blankline" end,
    },


    {
        "windwp/nvim-autopairs",
        version = "*",
        config = function() require "plugins/autopairs" end,
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        config = function() require "plugins/surround" end,
    },

    {
        "nvim-tree/nvim-web-devicons",
        version = "*",
        config = function() require "plugins/devicons" end,
    },

    {
        "shortcuts/no-neck-pain.nvim",
        version = "*",
        config = function() require("plugins.no-neck-pain").setup() end,
    },

    {
        "folke/zen-mode.nvim",
        version = "*",
        config = function() require "plugins/zen-mode" end,
    },

    -- NOTE: Doesn't work well with no-neck-pain:
    -- https://github.com/shortcuts/no-neck-pain.nvim/issues/221
    -- {
    --     "rmagatti/auto-session",
    --     version = "*",
    --     config = function() require "plugins/auto-session" end,
    -- },

    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/treesitter" end,
        build = ":TSUpdate",
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        version = "*",
        event = "BufEnter",
    },

    {
        "nkrkv/nvim-treesitter-rescript",
        version = "*",
    },

    -- lsp
    {
        "williamboman/mason.nvim",
        version = "*",
    },

    {
        "williamboman/mason-lspconfig.nvim",
        version = "*",
    },

    {
        "neovim/nvim-lspconfig",
        branch = "master",
        event = "BufEnter",
        config = function() require "plugins/lspconfig" end,
    },

    {
        "glepnir/lspsaga.nvim",
        branch = "main", -- TODO: Go back to stable after the current version is released
        event = "BufEnter",
        config = function() require "plugins/lspsaga" end,
    },

    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        branch = "main",
        event = "BufEnter",
        config = function() require "plugins/lsp-lines" end,
    },

    {
        "simrat39/rust-tools.nvim",
        version = "*",
        event = "BufEnter *.rs",
    },


    {
        "jose-elias-alvarez/null-ls.nvim",
        version = "*",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufEnter",
        config = function() require "plugins/null-ls" end,
    },

    {
        "folke/neodev.nvim",
        version = "*",
    },

    -- autocompletions
    {
        "hrsh7th/nvim-cmp",
        version = "*",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "onsails/lspkind.nvim",
        },
        config = function() require "plugins/cmp" end,
    },

    {
        "github/copilot.vim",
        version = "*",
    },

    {
        "L3MON4D3/LuaSnip",
        version = "*",
        event = "InsertEnter",
        config = function() require "plugins/luasnip" end,
    },

    -- file tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            {
                "s1n7ax/nvim-window-picker",
                event = "VeryLazy",
                version = "2.*",
                config = function() require "plugins/window-picker" end,
            },
        },
        config = function() require "plugins/neo-tree" end,
    },

    -- fuzzy finders
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function() require "plugins/telescope" end,
    },

    {
        "nvim-telescope/telescope-file-browser.nvim",
        version = "*",
    },

    -- bars
    {
        "nvim-lualine/lualine.nvim",
        version = "*",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function() require "plugins/lualine" end,
    },

    -- terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function() require "plugins/toggleterm" end,
    },

    -- git
    {
        "kdheepak/lazygit.nvim",
        version = "*",
    },

    {
        "sindrets/diffview.nvim",
        version = "*",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function() require "plugins/diffview" end,
    },

    {
        "lewis6991/gitsigns.nvim",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/gitsigns" end,
    },

    -- search/replace
    {
        "nvim-pack/nvim-spectre",
        version = "*",
        config = function() require "plugins/spectre" end,
    },

    -- comments
    {
        "numToStr/Comment.nvim",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/comment" end,
    },

    {
        "folke/todo-comments.nvim",
        version = "*",
        event = "BufEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function() require "plugins/todo-comments" end,
    },

    -- markdown
    {
        "iamcco/markdown-preview.nvim",
        version = "*",
        build = function() vim.fn["mkdp#util#install"]() end,
    },

    {
        "mzlogin/vim-markdown-toc",
        version = "*",
    },

    -- misc
    {
        "norcalli/nvim-colorizer.lua",
        version = "*",
        lazy = true,
        config = function() require "plugins/colorizer" end,
    },

}

local options = {
    defaults = {
        lazy = false,
        version = "*",
    },
    lockfile = "~/.config/user/cfg/nvim/lazy-lock.json", -- FIXME: It would be great to have it under nix
}

lazy.setup(plugins, options)
