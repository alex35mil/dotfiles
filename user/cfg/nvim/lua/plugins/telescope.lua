local plugin = require "telescope"
local actions = require "telescope.actions"
local fb = require "telescope._extensions.file_browser.actions"

local function copy_path(bufnr, fmt)
    local fs = require "utils.fs"
    local clipboard = require "utils.clipboard"
    local fb_utils = require "telescope._extensions.file_browser.utils"

    local selections = fb_utils.get_selected_files(bufnr, true)
    local entry = selections[1]

    if entry ~= nil then
        local result = fs.format(entry.filename, fmt)

        if result ~= nil then
            clipboard.yank(result)
        end
    else
        vim.api.nvim_err_writeln("No file selected")
    end
end

local extensions = {
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
                ["<C-a>"] = fb.create,
                ["<S-CR>"] = fb.create_from_prompt,
                ["<C-r>"] = fb.rename,
                ["<C-m>"] = fb.move,
                ["<C-y>"] = fb.copy,
                ["<C-d>"] = fb.remove,
                ["<C-o>"] = fb.open,
                ["<C-u>"] = fb.goto_parent_dir,
                ["<C-e>"] = false,
                ["<C-w>"] = fb.goto_cwd,
                ["<C-t>"] = false,
                ["<C-f>"] = fb.toggle_browser,
                ["<C-h>"] = fb.toggle_hidden,
                ["<C-s>"] = fb.toggle_all,
                ["<C-c>a"] = function(bufnr) copy_path(bufnr, "absolute") end,
                ["<C-c>r"] = function(bufnr) copy_path(bufnr, "relative") end,
                ["<C-c>n"] = function(bufnr) copy_path(bufnr, "filename") end,
                ["<C-c>s"] = function(bufnr) copy_path(bufnr, "filestem") end,
                ["<BS>"] = fb.backspace,
            },
            ["n"] = {
                ["a"] = fb.create,
                ["r"] = fb.rename,
                ["m"] = fb.move,
                ["y"] = fb.copy,
                ["d"] = fb.remove,
                ["o"] = fb.open,
                ["u"] = fb.goto_parent_dir,
                ["e"] = false,
                ["w"] = fb.goto_cwd,
                ["t"] = false,
                ["f"] = fb.toggle_browser,
                ["h"] = fb.toggle_hidden,
                ["s"] = fb.toggle_all,
                ["<C-c>a"] = function(bufnr) copy_path(bufnr, "absolute") end,
                ["<C-c>r"] = function(bufnr) copy_path(bufnr, "relative") end,
                ["<C-c>n"] = function(bufnr) copy_path(bufnr, "filename") end,
                ["<C-c>s"] = function(bufnr) copy_path(bufnr, "filestem") end,
            },
        },
    },
}

plugin.setup {
    defaults = {
        vimgrep_arguments = {
            "rg",
            "-L",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
            },
            vertical = {
                mirror = true,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
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
                ["<D-h>"] = actions.file_split,
                ["<D-n>"] = actions.file_vsplit,
                ["<C-t>"] = actions.preview_scrolling_up,
                ["<C-h>"] = actions.preview_scrolling_down,
                ["q"] = actions.close,
            },
            i = {
                ["<D-h>"] = actions.file_split,
                ["<D-n>"] = actions.file_vsplit,
                ["<C-t>"] = actions.preview_scrolling_up,
                ["<C-h>"] = actions.preview_scrolling_down,
            },
        },
    },
    extensions = extensions,
}

pcall(function()
    for ext, _ in pairs(extensions) do
        plugin.load_extension(ext)
    end
end)
