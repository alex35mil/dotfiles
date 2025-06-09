local Pickers = {}

local VerticalLayout = {}
local HorizontalLayout = {}

---@enum LayoutStrategy
local LayoutStrategy = {
    HORIZONTAL = "horizontal",
    VERTICAL = "vertical",
}

local fn = {}

NVTelescope = {
    "nvim-telescope/telescope.nvim",
    keys = function()
        return {
            { "<D-e>", Pickers.file_browser, mode = { "n", "i", "v" }, desc = "Open file browser" },
        }
    end,
    opts = function()
        local actions = require("telescope.actions")

        local grepargs = { NVSearch.cmd }

        for _, arg in ipairs(NVSearch.base_args) do
            table.insert(grepargs, arg)
        end

        table.insert(grepargs, NVSearch.optional_args.with_hidden)
        table.insert(grepargs, NVSearch.optional_args.smart_case)

        local mappings = {
            [NVKeymaps.scroll.up] = actions.preview_scrolling_up,
            [NVKeymaps.scroll.down] = actions.preview_scrolling_down,
            ["<D-CR>"] = actions.file_vsplit,
            ["<D-S-CR>"] = actions.file_split,
            ["<M-Up>"] = actions.move_to_top,
            ["<M-Right>"] = actions.move_to_middle,
            ["<M-Down>"] = actions.move_to_bottom,
            [NVKeymaps.close] = actions.close,
        }

        local buffer_mappings = {
            ["<D-BS>"] = actions.delete_buffer,
        }

        local git_branches_mappings = {
            ["<D-n>"] = actions.git_create_branch,
            ["<D-BS>"] = actions.git_delete_branch,
        }

        return {
            defaults = {
                vimgrep_arguments = grepargs,
                prompt_prefix = "   ",
                selection_caret = "  ",
                entry_prefix = "  ",
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "ascending",
                layout_strategy = LayoutStrategy.VERTICAL,
                layout_config = {
                    horizontal = HorizontalLayout.build(),
                    vertical = VerticalLayout.build(),
                },
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                file_ignore_patterns = { "%.git/", "node_modules" },
                generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                path_display = { "truncate" },
                winblend = 0,
                border = {},
                borderchars = {
                    prompt = { " ", "", "", "", "", "", "", "" },
                    results = { " ", "", "", "", "", "", "", "" },
                    preview = { " ", "", "", "", "", "", "", "" },
                },
                color_devicons = true,
                set_env = { ["COLORTERM"] = "truecolor" },
                file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
                buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
                mappings = {
                    n = mappings,
                    i = mappings,
                },
            },
            pickers = {
                buffers = {
                    mappings = {
                        n = buffer_mappings,
                        i = buffer_mappings,
                    },
                },
                git_branches = {
                    mappings = {
                        n = git_branches_mappings,
                        i = git_branches_mappings,
                    },
                },
                lsp_workspace_symbols = {},
            },
            extensions = {
                file_browser = NVTelescopeFileBrowser.options(),
            },
        }
    end,
}

NVTelescopeFileBrowser = {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("telescope").load_extension("file_browser")
    end,
}

function NVTelescopeFileBrowser.options()
    local ts = require("telescope.actions")
    local fb = require("telescope._extensions.file_browser.actions")

    local mappings = {
        ["<D-n>"] = fb.create,
        ["<S-CR>"] = fb.create_from_prompt,
        [NVKeymaps.rename] = fb.rename,
        [NVKarabiner["<D-m>"]] = fb.move,
        ["<D-d>"] = fb.copy, -- duplicate current file
        ["<D-v>"] = fb.copy, -- (copy)/paste selected file(s)
        ["<D-BS>"] = fb.remove,
        ["<D-o>"] = fb.open,
        ["<D-u>"] = fb.goto_parent_dir,
        ["<D-S-u>"] = fb.goto_cwd,
        ["<D-f>"] = fb.toggle_browser,
        ["<D-h>"] = fb.toggle_hidden,
        ["<D-a>"] = fb.toggle_all,
        ["<BS>"] = fb.backspace,
        ["<CR>"] = "select_default",
        ["<D-c>"] = function(bufnr)
            ts.toggle_selection(bufnr)
            ts.move_selection_worse(bufnr)
        end,
        ["<D-S-a>"] = function(bufnr)
            fn.copy_path(bufnr, "absolute")
        end,
        ["<D-S-r>"] = function(bufnr)
            fn.copy_path(bufnr, "relative")
        end,
        ["<D-S-n>"] = function(bufnr)
            fn.copy_path(bufnr, "filename")
        end,
        ["<D-S-s>"] = function(bufnr)
            fn.copy_path(bufnr, "filestem")
        end,
    }

    return {
        cwd_to_path = false,
        grouped = false,
        files = true,
        add_dirs = true,
        depth = 1,
        auto_depth = false,
        select_buffer = false,
        hidden = {
            file_browser = false,
            folder_browser = false,
        },
        respect_gitignore = false,
        -- browse_files
        -- browse_folders
        hide_parent_dir = false,
        collapse_dirs = false,
        prompt_path = false,
        quiet = false,
        display_stat = false,
        hijack_netrw = false,
        use_fd = true,
        git_status = true,
        mappings = {
            ["i"] = vim.tbl_extend("error", mappings, {
                ["<C-c>"] = false,
                ["<A-c>"] = false,
                ["<A-r>"] = false,
                ["<A-m>"] = false,
                ["<A-y>"] = false,
                ["<A-d>"] = false,
                ["<C-o>"] = false,
                ["<C-g>"] = false,
                ["<C-e>"] = false,
                ["<C-w>"] = false,
                ["<C-t>"] = false,
                ["<C-f>"] = false,
                ["<C-h>"] = false,
                ["<C-s>"] = false,
                ["<C-d>"] = false,
                ["<C-u>"] = false,
            }),
            ["n"] = vim.tbl_extend("error", mappings, {
                ["a"] = false,
                ["c"] = false,
                ["g"] = false,
                ["r"] = false,
                ["m"] = false,
                ["y"] = false,
                ["d"] = false,
                ["o"] = false,
                ["u"] = false,
                ["e"] = false,
                ["w"] = false,
                ["t"] = false,
                ["f"] = false,
                ["h"] = false,
                ["s"] = false,
                ["L"] = false,
                ["H"] = false,
                ["<C-d>"] = false,
                ["<C-u>"] = false,
            }),
        },
    }
end

VerticalLayout = {
    large_screen_width = 0.4,
    small_screen_width = 0.5,
}

function VerticalLayout.build(config)
    local default = {
        width = NVScreen.is_large() and VerticalLayout.large_screen_width or VerticalLayout.small_screen_width,
        height = 0.7,
        preview_cutoff = 1,
        prompt_position = "top",
        preview_height = 0.4,
        mirror = true,
    }

    if config then
        return vim.tbl_extend("force", default, config)
    else
        return default
    end
end

HorizontalLayout = {
    large_screen_width = 0.6,
    small_screen_width = 0.8,
}

function HorizontalLayout.build(config)
    local default = {
        prompt_position = "top",
        width = NVScreen.is_large() and HorizontalLayout.large_screen_width or HorizontalLayout.small_screen_width,
        preview_width = 0.5,
    }

    if config then
        return vim.tbl_extend("force", default, config)
    else
        return default
    end
end

function Pickers.file_browser()
    local extensions = require("telescope").extensions

    extensions.file_browser.file_browser({
        cwd = "%:p:h",
        hidden = true,
        git_status = true,
        respect_gitignore = false,
        grouped = true,
        select_buffer = true,
        initial_mode = "insert",
        file_ignore_patterns = { "%.git/" },
        layout_strategy = LayoutStrategy.HORIZONTAL,
        layout_config = {
            horizontal = HorizontalLayout.build(),
        },
    })
end

function NVTelescope.open_file_browser()
    Pickers.file_browser()
end

function fn.copy_path(bufnr, fmt)
    local fb = require("telescope._extensions.file_browser.utils")

    local selections = fb.get_selected_files(bufnr, true)
    local entry = selections[1]

    if entry ~= nil then
        local result = NVFS.format(entry.filename, fmt)

        if result ~= nil then
            NVClipboard.yank(result)
            log.info("Copied: " .. result)
        end
    else
        log.error("No file selected")
    end
end

return { NVTelescope, NVTelescopeFileBrowser }
