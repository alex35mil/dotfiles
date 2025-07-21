NVGit = {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "git_config",
                "gitcommit",
                "git_rebase",
                "gitignore",
                "gitattributes",
            },
        },
    },
}

return NVGit