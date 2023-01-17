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

    -- essentials
    {
        "echasnovski/mini.trailspace",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/mini-trailspace" end,
    },

    {
        "phaazon/hop.nvim",
        branch = "v2",
        event = "BufEnter",
        config = function() require "plugins/hop" end,
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
        "kyazdani42/nvim-web-devicons",
        version = "*",
        config = function() require "plugins/devicons" end,
    },

    {
        "rmagatti/auto-session",
        version = "*",
        config = function() require "plugins/auto-session" end,
    },

    {
        "folke/zen-mode.nvim",
        version = "*",
        config = function() require "plugins/zen-mode" end,
    },

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
        version = "*",
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
        "folke/trouble.nvim",
        version = "*",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function() require "plugins/trouble" end,
    },

    {
        "simrat39/rust-tools.nvim",
        version = "*",
        event = "BufEnter *.rs",
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
        "L3MON4D3/LuaSnip",
        version = "*",
        event = "InsertEnter",
        config = function() require "plugins/luasnip" end,
    },

    -- file tree
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function() require "plugins/tree" end,
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
        dependencies = { "kyazdani42/nvim-web-devicons" },
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
        "lewis6991/gitsigns.nvim",
        version = "*",
        event = "BufEnter",
        config = function() require "plugins/gitsigns" end,
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
        "folke/which-key.nvim",
        version = "*",
        config = function() require "plugins/which-key" end,
    },

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
