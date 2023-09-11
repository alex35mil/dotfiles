local M = {}

function M.setup()
    local plugin = require "diffview"
    local actions = require "diffview.actions"

    plugin.setup {
        enhanced_diff_hl = true,
        show_help_hints = false,
        watch_index = true,
        file_panel = {
            listing_style = "list", -- 'list' or 'tree'
        },
        keymaps = {
            disable_defaults = true,
            view = {
                { "n", "<Tab>",   actions.select_next_entry, { desc = "Open the diff for the next file" } },
                { "n", "<S-Tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                { "n", "gf",      actions.goto_file,         { desc = "Open the file in a new split in the previous tabpage" } },
                -- { "n", "",     actions.focus_files,       { desc = "Bring focus to the file panel" } },
                { "n", "<C-z>",   actions.toggle_files,      { desc = "Toggle the file panel." } },
                -- { "n", "",     actions.prev_conflict,             { desc = "In the merge-tool: jump to the previous conflict" } },
                -- { "n", "",     actions.next_conflict,             { desc = "In the merge-tool: jump to the next conflict" } },
                -- { "n", "",     actions.conflict_choose("ours"),   { desc = "Choose the OURS version of a conflict" } },
                -- { "n", "",     actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
                -- { "n", "",     actions.conflict_choose("base"),   { desc = "Choose the BASE version of a conflict" } },
                -- { "n", "",     actions.conflict_choose("all"),    { desc = "Choose all the versions of a conflict" } },
                -- { "n", "",     actions.conflict_choose("none"),   { desc = "Delete the conflict region" } },
            },
            file_panel = {
                { "n", "t",             actions.prev_entry,          { desc = "Bring the cursor to the previous file entry." } },
                { "n", "h",             actions.next_entry,          { desc = "Bring the cursor to the next file entry" } },
                { "n", "<Up>",          actions.select_prev_entry,   { desc = "Open the diff for the previous file" } },
                { "n", "<Down>",        actions.select_next_entry,   { desc = "Open the diff for the next file" } },
                { "n", "<S-Tab>",       actions.select_prev_entry,   { desc = "Open the diff for the previous file" } },
                { "n", "<Tab>",         actions.select_next_entry,   { desc = "Open the diff for the next file" } },
                { "n", "<CR>",          actions.select_entry,        { desc = "Open the diff for the selected entry." } },
                { "n", "<2-LeftMouse>", actions.select_entry,        { desc = "Open the diff for the selected entry." } },
                { "n", "<C-t>",         actions.scroll_view(-0.25),  { desc = "Scroll the view up" } },
                { "n", "<C-h>",         actions.scroll_view(0.25),   { desc = "Scroll the view down" } },
                { "n", "<Space>",       actions.toggle_stage_entry,  { desc = "Stage / unstage the selected entry." } },
                { "n", "A",             actions.stage_all,           { desc = "Stage all entries." } },
                { "n", "U",             actions.unstage_all,         { desc = "Unstage all entries." } },
                { "n", "X",             actions.restore_entry,       { desc = "Restore entry to the state on the left side." } },
                { "n", "gf",            actions.goto_file,           { desc = "Open the file" } },
                { "n", "i",             actions.listing_style,       { desc = "Toggle between 'list' and 'tree' views" } },
                { "n", "d",             actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories." } },
                { "n", "L",             actions.open_commit_log,     { desc = "Open the commit log panel." } },
                { "n", "R",             actions.refresh_files,       { desc = "Update stats and entries in the file list." } },
                -- { "n", "",           actions.focus_files,         { desc = "Bring focus to the file panel" } },
                { "n", "<C-z>",         actions.toggle_files,        { desc = "Toggle the file panel" } },
                -- { "n", "",           actions.prev_conflict,       { desc = "Go to the previous conflict" } },
                -- { "n", "",           actions.next_conflict,       { desc = "Go to the next conflict" } },
                { "n", "?",             actions.help("file_panel"),  { desc = "Open the help panel" } },
            },
        },
        hooks = {
            diff_buf_win_enter = function(bufnr, winid, ctx)
                if ctx.layout_name:match("^diff2") then
                    if ctx.symbol == "a" then
                        vim.opt_local.winhl = table.concat(
                            {
                                "DiffAdd:DiffviewDiffDelete",
                                "DiffDelete:DiffviewDiffFill",
                                "DiffChange:DiffviewDiffDelete",
                                "DiffText:DiffviewDiffDeleteText",
                            },
                            ","
                        )
                    elseif ctx.symbol == "b" then
                        vim.opt_local.winhl = table.concat(
                            {
                                "DiffAdd:DiffviewDiffAdd",
                                "DiffChange:DiffviewDiffAdd",
                                "DiffText:DiffviewDiffAddText",
                                "DiffDelete:DiffviewDiffFill",
                            },
                            ","
                        )
                    end
                end
            end,
        },
    }
end

return M
