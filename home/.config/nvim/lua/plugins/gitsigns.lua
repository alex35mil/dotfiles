local M = {}

function M.setup()
    local plugin = require "gitsigns"

    plugin.setup {
        signs = {
            add          = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
            change       = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
            delete       = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
            topdelete    = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
            changedelete = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
            untracked    = { hl = "GitSignsAdd", text = "⋅", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        },
        _signs_staged_enable = true,
        _signs_staged = {
            add          = { hl = "GitSignsStagedAdd", text = "▎", numhl = "GitSignsStagedAddNr", linehl = "GitSignsStagedAddLn" },
            change       = { hl = "GitSignsStagedChange", text = "▎", numhl = "GitSignsStagedChangeNr", linehl = "GitSignsStagedChangeLn" },
            delete       = { hl = "GitSignsStagedDelete", text = "契", numhl = "GitSignsStagedDeleteNr", linehl = "GitSignsStagedDeleteLn" },
            topdelete    = { hl = "GitSignsStagedDelete", text = "契", numhl = "GitSignsStagedDeleteNr", linehl = "GitSignsStagedDeleteLn" },
            changedelete = { hl = "GitSignsStagedChange", text = "▎", numhl = "GitSignsStagedChangeNr", linehl = "GitSignsStagedChangeLn" },
            untracked    = { hl = "GitSignsStagedAdd", text = "⋅", numhl = "GitSignsStagedAddNr", linehl = "GitSignsStagedAddLn" },
        },
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
            interval = 1000,
            follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
        },
        current_line_blame_formatter_opts = {
            relative_time = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000,
        preview_config = {
            -- Options passed to nvim_open_win
            border = "rounded",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
        },
        yadm = {
            enable = false,
        },

    }
end

return M
