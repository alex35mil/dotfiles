-- TODO: Setup or remove neo-tree

NVNeoTree = {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
        filesystem = {
            filtered_items = {
                hide_dotfiles = false,
                hide_gitignored = false,
            },
        },
    },
}

return { NVNeoTree }
