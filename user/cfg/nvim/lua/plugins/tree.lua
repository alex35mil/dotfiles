local plugin = require "nvim-tree"

plugin.setup {
    filters = {
        dotfiles = false,
        custom = { "^\\.git$" },
    },
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    hijack_cursor = true,
    hijack_unnamed_buffer_when_opening = false,
    sync_root_with_cwd = false,
    hijack_directories = {
        enable = true,
        auto_open = false,
    },
    update_focused_file = {
        enable = true,
        update_cwd = false,
    },
    view = {
        adaptive_size = false,
        side = "left",
        width = 30,
        hide_root_folder = false,
        mappings = {
            list = {
                { key = "<C-e>", action = "" },
            },
        },
    },
    git = {
        enable = true,
        ignore = false,
    },
    filesystem_watchers = {
        enable = true,
    },
    actions = {
        open_file = {
            resize_window = true,
        },
        change_dir = {
            enable = false,
            global = false,
            restrict_above_cwd = true,
        },
    },
    renderer = {
        highlight_git = true,
        highlight_opened_files = "none",

        root_folder_label = function(path)
            local project = vim.fn.fnamemodify(path, ":t")
            return string.upper(project)
        end,

        indent_markers = {
            enable = true,
        },

        icons = {
            webdev_colors = false,
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
            },
            glyphs = {
                default = "",
                symlink = "",
                folder = {
                    default = "",
                    empty = "",
                    empty_open = "",
                    open = "",
                    symlink = "",
                    symlink_open = "",
                    arrow_open = "",
                    arrow_closed = "",
                },
                git = {
                    staged = "✓",
                    deleted = "",
                    renamed = "➜",
                    unstaged = "",
                    -- unstaged = "✗",
                    unmerged = "",
                    -- unmerged = "",
                    untracked = "",
                    -- untracked = "★",
                    ignored = "",
                    -- ignored = "◌",
                },
            },
        },
    },
}
