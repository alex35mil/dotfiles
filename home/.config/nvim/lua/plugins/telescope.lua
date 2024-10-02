local Pickers = {}

local fn = {}

NVTelescope = {
    "nvim-telescope/telescope.nvim",
    keys = function()
        return {
            { "<D-e>", Pickers.file_browser, mode = { "n", "i", "v" }, desc = "Open file browser" },
            { "<D-t>", Pickers.file_finder, mode = { "n", "i", "v" }, desc = "Open file finder" },
            { "<D-b>", Pickers.buffers, mode = { "n", "i", "v" }, desc = "Open buffer picker" },
            { "<D-f>", Pickers.text_finder, mode = { "n", "i", "v" }, desc = "Open text finder" },
            { "<D-g>b", Pickers.git_branches, mode = { "n", "i", "v" }, desc = "Git: Branches" },
            { "<D-S-o>", Pickers.lsp_workspace_symbols, mode = { "n", "i", "v" }, desc = "LSP: Open workspace symbols" },
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
                layout_strategy = "vertical",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        width = NVScreen.is_large() and 0.55 or 0.8,
                        preview_width = 0.5,
                    },
                    vertical = {
                        width = NVScreen.is_large() and 0.4 or 0.5,
                        height = 0.7,
                        preview_cutoff = 1,
                        prompt_position = "top",
                        preview_height = 0.4,
                        mirror = true,
                    },
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

        -- TODO: Review default LazyVim configuration

        -- local actions = require("telescope.actions")
        --
        -- local open_with_trouble = function(...)
        --     return require("trouble.sources.telescope").open(...)
        -- end
        -- local find_files_no_ignore = function()
        --     local action_state = require("telescope.actions.state")
        --     local line = action_state.get_current_line()
        --     LazyVim.pick("find_files", { no_ignore = true, default_text = line })()
        -- end
        -- local find_files_with_hidden = function()
        --     local action_state = require("telescope.actions.state")
        --     local line = action_state.get_current_line()
        --     LazyVim.pick("find_files", { hidden = true, default_text = line })()
        -- end
        --
        -- local function find_command()
        --     if 1 == vim.fn.executable("rg") then
        --         return { "rg", "--files", "--color", "never", "-g", "!.git" }
        --     elseif 1 == vim.fn.executable("fd") then
        --         return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        --     elseif 1 == vim.fn.executable("fdfind") then
        --         return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        --     elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
        --         return { "find", ".", "-type", "f" }
        --     elseif 1 == vim.fn.executable("where") then
        --         return { "where", "/r", ".", "*" }
        --     end
        -- end
        --
        -- return {
        --     defaults = {
        --         borderchars = {
        --             prompt = { "", "", "", "", "", "", "", "" },
        --             results = { "", "", "", "", "", "", "", "" },
        --             preview = { "", "", "", "", "", "", "", "" },
        --         },
        --         prompt_prefix = "   ",
        --         selection_caret = " ",
        --         -- open files in the first window that is an actual file.
        --         -- use the current window if no other window is available.
        --         get_selection_window = function()
        --             local wins = vim.api.nvim_list_wins()
        --             table.insert(wins, 1, vim.api.nvim_get_current_win())
        --             for _, win in ipairs(wins) do
        --                 local buf = vim.api.nvim_win_get_buf(win)
        --                 if vim.bo[buf].buftype == "" then
        --                     return win
        --                 end
        --             end
        --             return 0
        --         end,
        --         mappings = {
        --             i = {
        --                 ["<c-t>"] = open_with_trouble,
        --                 ["<a-t>"] = open_with_trouble,
        --                 ["<a-i>"] = find_files_no_ignore,
        --                 ["<a-h>"] = find_files_with_hidden,
        --                 ["<C-Down>"] = actions.cycle_history_next,
        --                 ["<C-Up>"] = actions.cycle_history_prev,
        --                 ["<C-f>"] = actions.preview_scrolling_down,
        --                 ["<C-b>"] = actions.preview_scrolling_up,
        --             },
        --             n = {
        --                 ["q"] = actions.close,
        --             },
        --         },
        --     },
        --     pickers = {
        --         find_files = {
        --             find_command = find_command,
        --             hidden = true,
        --         },
        --     },
        -- }
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
        ["<D-r>"] = fb.rename,
        [NVKarabiner["<D-m>"]] = fb.move,
        ["<D-d>"] = fb.copy,
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
        layout_strategy = "horizontal",
    })
end

function Pickers.buffers()
    local telescope = require("telescope.builtin")

    local listed_buffers = NVBuffers.get_listed_bufs()

    telescope.buffers({
        initial_mode = "insert",
        sort_mru = true,
        ignore_current_buffer = #listed_buffers > 1,
    })
end

function Pickers.file_finder()
    local telescope = require("telescope.builtin")

    telescope.find_files({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
        layout_strategy = "vertical",
    })
end

function Pickers.text_finder()
    local telescope = require("telescope.builtin")

    telescope.live_grep({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
        layout_strategy = "horizontal",
    })
end

function Pickers.git_branches()
    local telescope = require("telescope.builtin")

    telescope.git_branches({
        initial_mode = "insert",
    })
end

function Pickers.lsp_workspace_symbols()
    local telescope = require("telescope.builtin")

    local large_screen = NVScreen.is_large()

    telescope.lsp_dynamic_workspace_symbols({
        initial_mode = "insert",
        fname_width = large_screen and 40 or 30,
        symbol_width = large_screen and 40 or 30,
        layout_strategy = "vertical",
        layout_config = {
            vertical = {
                width = large_screen and 0.5 or 0.8,
                height = 0.9,
                preview_cutoff = 1,
                prompt_position = "top",
                preview_height = 0.6,
                mirror = true,
            },
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
            print("Copied: " .. result)
        end
    else
        vim.api.nvim_err_writeln("No file selected")
    end
end

return { NVTelescope, NVTelescopeFileBrowser }
