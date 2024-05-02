local M = {}
local X = {}
local m = {}

function M.setup()
    local plugin = require "telescope"
    local actions = require "telescope.actions"
    local editor = require "editor.searchreplace"
    local extensions = X.extensions()

    local grepargs = { editor.search.cmd }

    for _, arg in ipairs(editor.search.base_args) do
        table.insert(grepargs, arg)
    end

    table.insert(grepargs, editor.search.optional_args.with_hidden)
    table.insert(grepargs, editor.search.optional_args.smart_case)

    plugin.setup {
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
                    width = 0.8,
                    preview_width = 0.5,
                },
                vertical = {
                    width = 0.5,
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
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            color_devicons = true,
            set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
            file_previewer = require("telescope.previewers").vim_buffer_cat.new,
            grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
            qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
            -- Developer configurations: Not meant for general override
            buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
            mappings = {
                n = {
                    ["<S-Down>"] = actions.file_split,
                    ["<S-Right>"] = actions.file_vsplit,
                    ["<C-t>"] = actions.preview_scrolling_up,
                    ["<C-h>"] = actions.preview_scrolling_down,
                    ["<D-w>"] = actions.close,
                },
                i = {
                    ["<S-Down>"] = actions.file_split,
                    ["<S-Right>"] = actions.file_vsplit,
                    ["<C-t>"] = actions.preview_scrolling_up,
                    ["<C-h>"] = actions.preview_scrolling_down,
                    ["<D-w>"] = actions.close,
                },
            },
        },
        pickers = {
            buffers = {
                mappings = {
                    n = { ["<D-BS>"] = actions.delete_buffer },
                    i = { ["<D-BS>"] = actions.delete_buffer },
                },
            },
        },
        extensions = extensions,
    }

    pcall(
        function()
            for ext, _ in pairs(extensions) do
                plugin.load_extension(ext)
            end
        end
    )
end

-- Extensions

function X.extensions()
    local fb = require "telescope._extensions.file_browser.actions"

    return {
        file_browser = {
            -- path
            -- cwd
            cwd_to_path = false,
            grouped = false,
            files = true,
            add_dirs = true,
            depth = 1,
            auto_depth = false,
            select_buffer = false,
            hidden = { file_browser = false, folder_browser = false },
            respect_gitignore = false,
            -- browse_files
            -- browse_folders
            hide_parent_dir = false,
            collapse_dirs = false,
            prompt_path = false,
            quiet = false,
            dir_icon = "",
            dir_icon_hl = "Default",
            display_stat = false,
            hijack_netrw = false,
            use_fd = true,
            git_status = true,
            mappings = {
                ["i"] = {
                    ["<D-n>"] = fb.create,
                    ["<S-CR>"] = fb.create_from_prompt,
                    ["<D-r>"] = fb.rename,
                    ["<C-M-S-m>"] = fb.move, -- <D-m> remapped via Karabiner
                    ["<D-d>"] = fb.copy,
                    ["<D-BS>"] = fb.remove,
                    ["<D-o>"] = fb.open,
                    ["<D-u>"] = fb.goto_parent_dir,
                    ["<D-M-u>"] = fb.goto_cwd,
                    ["<D-f>"] = fb.toggle_browser,
                    ["<D-h>"] = fb.toggle_hidden,
                    ["<D-a>"] = fb.toggle_all,
                    ["<BS>"] = fb.backspace,
                    ["<CR>"] = "select_default",
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
                },
                ["n"] = {
                    ["<D-n>"] = fb.create,
                    ["<S-CR>"] = fb.create_from_prompt,
                    ["<D-r>"] = fb.rename,
                    ["<C-M-S-m>"] = fb.move, -- <D-m> remapped via Karabiner
                    ["<D-d>"] = fb.copy,
                    ["<D-BS>"] = fb.remove,
                    ["<D-o>"] = fb.open,
                    ["<D-u>"] = fb.goto_parent_dir,
                    ["<D-M-u>"] = fb.goto_cwd,
                    ["<D-f>"] = fb.toggle_browser,
                    ["<D-h>"] = fb.toggle_hidden,
                    ["<D-a>"] = fb.toggle_all,
                    ["ya"] = function(bufnr) m.copy_path(bufnr, "absolute") end,
                    ["yr"] = function(bufnr) m.copy_path(bufnr, "relative") end,
                    ["yn"] = function(bufnr) m.copy_path(bufnr, "filename") end,
                    ["ys"] = function(bufnr) m.copy_path(bufnr, "filestem") end,
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
                },
            },
        },
    }
end

function M.keymaps()
    K.map { "<D-e>", "Open file browser", m.open_file_browser, mode = { "n", "i", "v" } }

    K.map { "<D-b>", "Open buffer selector", m.open_buffers, mode = { "n", "i", "v" } }
    K.map { "<D-t>", "Open file finder", m.open_file_finder, mode = { "n", "i", "v" } }
    K.map { "<D-f>", "Open project-wide text search", m.open_text_finder, mode = { "n", "i", "v" } }

    K.mapseq { "<Leader>tc", "Open command finder", m.open_command_finder, mode = "n" }
    K.mapseq { "<Leader>th", "Open highlights finder", "<Cmd>Telescope highlights<CR>", mode = "n" }

    K.mapseq {
        "<Leader>tta",
        "Find all TODO comments",
        function() m.open_todos({ todo = true, fixme = true }) end,
        mode = "n",
    }
    K.mapseq {
        "<Leader>ttt",
        "Find all TODOs",
        function() m.open_todos({ todo = true }) end,
        mode = "n",
    }
    K.mapseq {
        "<Leader>ttf",
        "Find all FIXMEs",
        function() m.open_todos({ fixme = true }) end,
        mode = "n",
    }
    K.mapseq {
        "<Leader>ttp",
        "Find all high priority entries",
        function() m.open_todos({ priority = true }) end,
        mode = "n",
    }

    K.map { "<D-o>", "Open document symbols", m.open_document_symbols, mode = "n" }
    K.map { "<D-O>", "Open workspace symbols", m.open_workspace_symbols, mode = "n" }

    K.map {
        "<D-.>",
        "List LSP diagnostics with ERROR severity for the whole workspace",
        function() m.open_diagnostics({ min_severity = "ERROR", current_buffer = false }) end,
        mode = { "n", "v" },
    }
    K.map {
        "<D-,>",
        "List LSP diagnostics with WARN & ERROR severities for the whole workspace",
        function() m.open_diagnostics({ min_severity = "WARN", current_buffer = false }) end,
        mode = { "n", "v" },
    }
    K.mapseq {
        "<Leader>da",
        "List all LSP diagnostics for the whole workspace",
        function() m.open_diagnostics({ current_buffer = false }) end,
        mode = { "n", "v" },
    }
    K.mapseq {
        "<Leader>de",
        "List LSP diagnostics with ERROR severity for the whole workspace",
        function() m.open_diagnostics({ min_severity = "ERROR", current_buffer = false }) end,
        mode = { "n", "v" },
    }
    K.mapseq {
        "<Leader>dw",
        "List LSP diagnostics with WARN & ERROR severities for the whole workspace",
        function() m.open_diagnostics({ min_severity = "WARN", current_buffer = false }) end,
        mode = { "n", "v" },
    }
    K.mapseq {
        "<Leader>dca",
        "List all LSP diagnostics for the current buffer only",
        function() m.open_diagnostics({ current_buffer = true }) end,
        mode = { "n", "v" },
    }
    K.mapseq {
        "<Leader>dce",
        "List LSP diagnostics with ERROR severity for the current buffer only",
        function() m.open_diagnostics({ min_severity = "ERROR", current_buffer = true }) end,
        mode = { "n", "v" },
    }
    K.mapseq {
        "<Leader>dcw",
        "List LSP diagnostics with WARN & ERROR severities for the current buffer only",
        function() m.open_diagnostics({ min_severity = "WARN", current_buffer = true }) end,
        mode = { "n", "v" },
    }
end

-- Private

local wide_layout_config = {
    width = 0.8,
}

function m.open_file_browser()
    local extensions = require "telescope".extensions

    extensions.file_browser.file_browser({
        cwd = "%:p:h",
        hidden = true,
        git_status = true,
        respect_gitignore = false,
        grouped = true,
        select_buffer = true,
        initial_mode = "normal",
        file_ignore_patterns = { "%.git/" },
        layout_strategy = "horizontal",
        layout_config = {
            width = 0.8,
            preview_width = 0.5,
        },
    })
end

function m.open_buffers()
    local telescope = require "telescope.builtin"
    local buffers = require "editor.buffers"

    local listed_buffers = buffers.get_listed_bufs()

    telescope.buffers({
        initial_mode = "insert",
        sort_mru = true,
        ignore_current_buffer = #listed_buffers > 1,
    })
end

function m.open_file_finder()
    local telescope = require "telescope.builtin"

    telescope.find_files({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
        layout_strategy = "vertical",
    })
end

function m.open_text_finder()
    local telescope = require "telescope.builtin"

    telescope.live_grep({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
        layout_strategy = "horizontal",
    })
end

function m.open_diagnostics(params)
    local telescope = require "telescope.builtin"

    local opts = {
        initial_mode = "normal",
        layout_strategy = "vertical",
        layout_config = wide_layout_config,
    }

    if params.current_buffer then
        opts.bufnr = 0
    end

    if params.min_severity then
        opts.severity_bound = "ERROR"
        opts.severity_limit = params.min_severity
    end

    telescope.diagnostics(opts)
end

function m.open_document_symbols()
    local telescope = require "telescope.builtin"

    telescope.lsp_document_symbols({
        initial_mode = "insert",
        layout_strategy = "vertical",
    })
end

function m.open_workspace_symbols()
    local telescope = require "telescope.builtin"

    telescope.lsp_workspace_symbols({
        initial_mode = "insert",
        layout_strategy = "vertical",
    })
end

function m.open_todos(params)
    if not params.todo and not params.fixme and not params.priority then
        vim.api.nvim_err_writeln "No keywords specified"
        return
    end

    local keywords = {}
    if params.priority then
        table.insert(keywords, "TODO!")
        table.insert(keywords, "FIXME!")
    else
        if params.todo then
            table.insert(keywords, "TODO")
            table.insert(keywords, "TODO!")
        end
        if params.fixme then
            table.insert(keywords, "FIXME")
            table.insert(keywords, "FIXME!")
        end
    end

    vim.cmd(
        "TodoTelescope " ..
        "keywords=" .. table.concat(keywords, ",") .. " " ..
        "layout_strategy=vertical layout_config={width=0.7}"
    )
end

function m.open_command_finder()
    local telescope = require "telescope.builtin"

    telescope.commands({
        initial_mode = "insert",
        layout_strategy = "vertical",
        layout_config = wide_layout_config,
    })
end

-- Utils

function m.copy_path(bufnr, fmt)
    local cb = require "editor.clipboard"
    local fs = require "editor.fs"
    local fb = require "telescope._extensions.file_browser.utils"

    local selections = fb.get_selected_files(bufnr, true)
    local entry = selections[1]

    if entry ~= nil then
        local result = fs.format(entry.filename, fmt)

        if result ~= nil then
            cb.yank(result)
            print("Copied to clipboard: " .. result)
            vim.defer_fn(function() vim.cmd.echo('""') end, 5000)
        end
    else
        vim.api.nvim_err_writeln("No file selected")
    end
end

return M
