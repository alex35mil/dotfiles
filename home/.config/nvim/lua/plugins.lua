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
        config = require("plugins.which-key").setup,
    },

    -- welcome screen
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = require("plugins.alpha").setup,
    },

    -- essentials
    {
        "echasnovski/mini.trailspace",
        version = "*",
        event = "BufEnter",
        config = require("plugins.mini-trailspace").setup,
    },

    {
        "rlane/pounce.nvim",
        version = "*",
        event = "BufEnter",
        config = require("plugins.pounce").setup,
    },

    {
        "xiyaowong/virtcolumn.nvim",
        version = "*",
        event = "BufEnter",
        config = require("plugins.virtcolumn").setup,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        version = "*",
        config = require("plugins.indent-blankline").setup,
    },


    {
        "windwp/nvim-autopairs",
        version = "*",
        config = require("plugins.autopairs").setup,
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        config = require("plugins.surround").setup,
    },

    {
        "nvim-tree/nvim-web-devicons",
        version = "*",
        config = require("plugins.devicons").setup,
    },

    {
        "shortcuts/no-neck-pain.nvim",
        version = "*",
        config = require("plugins.no-neck-pain").setup,
    },

    {
        "folke/zen-mode.nvim",
        version = "*",
        config = require("plugins.zen-mode").setup,
    },

    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        config = require("plugins.persistence").setup,
    },

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        config = require("plugins.noice").setup,
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
    },

    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        event = "BufEnter",
        config = require("plugins.treesitter").setup,
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
        config = require("plugins.lsp.lspconfig").setup,
    },

    {
        "glepnir/lspsaga.nvim",
        branch = "main", -- TODO: Go back to stable after the current version is released
        event = "BufEnter",
        config = require("plugins.lsp.lspsaga").setup,
    },

    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        branch = "main",
        event = "BufEnter",
        config = require("plugins.lsp.lsp-lines").setup,
    },

    {
        "simrat39/rust-tools.nvim",
        version = "*",
        event = "BufEnter *.rs",
    },


    {
        "stevearc/conform.nvim",
        version = "*",
        event = "BufEnter",
        config = require("plugins.lsp.conform").setup,
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
        config = require("plugins.cmp").setup,
    },

    {
        "github/copilot.vim",
        version = "*",
    },

    {
        "L3MON4D3/LuaSnip",
        version = "*",
        event = "InsertEnter",
        config = require("plugins.luasnip").setup,
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
                config = require("plugins.window-picker").setup,
            },
        },
        config = require("plugins.neo-tree").setup,
    },

    -- fuzzy finders
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = require("plugins.telescope").setup,
    },

    {
        "nvim-telescope/telescope-file-browser.nvim",
        version = "*",
    },

    -- window management
    {
        "sindrets/winshift.nvim",
        version = "*",
        event = "VimEnter",
        config = require("plugins.winshift").setup,
    },

    -- tab & status bar
    {
        "nvim-lualine/lualine.nvim",
        version = "*",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = require("plugins.lualine").setup,
    },

    -- terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = require("plugins.toggleterm").setup,
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
        config = require("plugins.git.diffview").setup,
    },

    {
        "lewis6991/gitsigns.nvim",
        branch = "main",
        event = "BufEnter",
        config = require("plugins.git.gitsigns").setup,
    },

    -- search/replace
    {
        "nvim-pack/nvim-spectre",
        version = "*",
        config = require("plugins.spectre").setup,
    },

    -- comments
    {
        "numToStr/Comment.nvim",
        version = "*",
        event = "BufEnter",
        config = require("plugins.comment").setup,
    },

    {
        "folke/todo-comments.nvim",
        version = "*",
        event = "BufEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = require("plugins.todo-comments").setup,
    },

    -- markdown
    {
        "iamcco/markdown-preview.nvim",
        version = "*",
        build = require("plugins.markdown-preview").setup,
    },

    {
        "mzlogin/vim-markdown-toc",
        version = "*",
    },

    -- misc
    {
        "tenxsoydev/tabs-vs-spaces.nvim",
        version = "*",
        config = require("plugins.tabs-vs-spaces").setup,
    },

    {
        "norcalli/nvim-colorizer.lua",
        version = "*",
        lazy = true,
        config = require("plugins.colorizer").setup,
    },

}

local options = {
    defaults = {
        lazy = false,
        version = "*",
    },
    lockfile = "~/.config/nvim/lazy-lock.json",
}

lazy.setup(plugins, options)
