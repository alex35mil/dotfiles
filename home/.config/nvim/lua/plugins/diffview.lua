local fn = {}

NVDiffview = {
    "sindrets/diffview.nvim",
    keys = function()
        return {
            { "<D-g>d", fn.toggle_diff, mode = { "n", "v", "i" }, desc = "Git: Toggle diff" },
        }
    end,
    opts = function()
        local actions = require("diffview.actions")

        return {
            enhanced_diff_hl = true,
            show_help_hints = false,
            watch_index = true,
            file_panel = {
                listing_style = "tree", -- 'list' or 'tree'
            },
            keymaps = {
                disable_defaults = true,
                view = {
                    { "n", "<Tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                    { "n", "<S-Tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                    { "n", "gf", actions.goto_file_edit, { desc = "Open the file" } },
                    -- { "n", "",     actions.focus_files,       { desc = "Bring focus to the file panel" } },
                    { "n", "<C-z>", actions.toggle_files, { desc = "Toggle the file panel." } },
                    -- { "n", "",     actions.prev_conflict,             { desc = "In the merge-tool: jump to the previous conflict" } },
                    -- { "n", "",     actions.next_conflict,             { desc = "In the merge-tool: jump to the next conflict" } },
                    -- { "n", "",     actions.conflict_choose("ours"),   { desc = "Choose the OURS version of a conflict" } },
                    -- { "n", "",     actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
                    -- { "n", "",     actions.conflict_choose("base"),   { desc = "Choose the BASE version of a conflict" } },
                    -- { "n", "",     actions.conflict_choose("all"),    { desc = "Choose all the versions of a conflict" } },
                    -- { "n", "",     actions.conflict_choose("none"),   { desc = "Delete the conflict region" } },
                },
                file_panel = {
                    { "n", "<Up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
                    { "n", "<Down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
                    { "n", "<M-Up>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                    { "n", "<M-Down>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                    { "n", "<S-Tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                    { "n", "<Tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                    { "n", "<Left>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
                    { "n", "<Right>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
                    { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
                    { "n", NVKeymaps.scroll.up, actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                    { "n", NVKeymaps.scroll.down, actions.scroll_view(0.25), { desc = "Scroll the view down" } },
                    { "n", "<Space>", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry." } },
                    { "n", "A", actions.stage_all, { desc = "Stage all entries." } },
                    { "n", "U", actions.unstage_all, { desc = "Unstage all entries." } },
                    { "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side." } },
                    { "n", "<CR>", actions.goto_file_edit, { desc = "Open the file" } },
                    { "n", "i", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
                    { "n", "d", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories." } },
                    { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel." } },
                    { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list." } },
                    -- { "n", "",           actions.focus_files,         { desc = "Bring focus to the file panel" } },
                    { "n", "<C-z>", actions.toggle_files, { desc = "Toggle the file panel" } },
                    -- { "n", "",           actions.prev_conflict,       { desc = "Go to the previous conflict" } },
                    -- { "n", "",           actions.next_conflict,       { desc = "Go to the next conflict" } },
                    { "n", "?", actions.help("file_panel"), { desc = "Open the help panel" } },
                },
            },
            hooks = {
                diff_buf_win_enter = function(_bufnr, _winid, ctx)
                    if ctx.layout_name:match("^diff2") then
                        if ctx.symbol == "a" then
                            vim.opt_local.winhl = table.concat({
                                "DiffAdd:DiffviewDiffDelete",
                                "DiffDelete:DiffviewDiffFill",
                                "DiffChange:DiffviewDiffDelete",
                                "DiffText:DiffviewDiffDeleteText",
                            }, ",")
                        elseif ctx.symbol == "b" then
                            vim.opt_local.winhl = table.concat({
                                "DiffAdd:DiffviewDiffAdd",
                                "DiffChange:DiffviewDiffAdd",
                                "DiffText:DiffviewDiffAddText",
                                "DiffDelete:DiffviewDiffFill",
                            }, ",")
                        end
                    end
                end,
            },
        }
    end,
}

function NVDiffview.ensure_current_hidden()
    local current_diff = fn.current_diff()

    if current_diff ~= nil then
        fn.hide_current_diff()
        return true
    else
        return false
    end
end

function NVDiffview.ensure_all_hidden()
    local current_diff = fn.current_diff()

    if current_diff ~= nil then
        fn.hide_current_diff()
    end

    local inactive_diff_tab = fn.inactive_diff()

    if inactive_diff_tab ~= nil then
        vim.api.nvim_command("tabclose " .. inactive_diff_tab)
    end
end

function fn.toggle_diff()
    local current_diff = fn.current_diff()

    if current_diff ~= nil then
        fn.hide_current_diff()
    else
        NVZenMode.ensure_deacitvated()

        local inactive_diff_tab = fn.inactive_diff()

        if inactive_diff_tab ~= nil then
            vim.api.nvim_set_current_tabpage(inactive_diff_tab)
        else
            fn.open_diff()
            NVLualine.rename_tab("diff")
            NVLualine.show_tabline()
        end
    end
end

function fn.open_diff()
    vim.cmd("DiffviewOpen")
end

function fn.hide_current_diff()
    vim.cmd("DiffviewClose")
end

function fn.current_diff()
    local dv = require("diffview.lib")

    local current_diff = dv.get_current_view()

    return current_diff
end

function fn.inactive_diff()
    local dv = require("diffview.lib")

    local tabs = vim.api.nvim_list_tabpages()

    for _, tabpage in ipairs(tabs) do
        for _, view in ipairs(dv.views) do
            if view.tabpage == tabpage then
                return tabpage
            end
        end
    end

    return nil
end

return { NVDiffview }
