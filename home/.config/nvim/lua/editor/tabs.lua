---@class TabLabel
---@field icon string
---@field name string

NVTabs = {
    editor_icon = "",
}

local fn = {}

function NVTabs.keymaps()
    K.map({ "<D-S-m>", "Make new tab", fn.create_tab, mode = { "n", "i", "v", "t" } })
    K.map({ "<C-S-m>", "Make new tab with git worktree", fn.create_tab_with_worktree, mode = { "n", "i", "v", "t" } })
    K.map({ NVKeyRemaps["<D-h>"], "Switch worktree", fn.pick_worktree, mode = { "n", "i", "v", "t" } })
    K.map({ "<C-w>", "Close tab", fn.close_tab, mode = { "n", "i", "v", "t" }, nowait = true })
    K.map({ "<C-S-n>", "Next tab", "<Cmd>tabnext<CR>", mode = { "n", "i", "v", "t" } })
    K.map({ "<C-S-d>", "Previous tab", "<Cmd>tabprev<CR>", mode = { "n", "i", "v", "t" } })
end

function fn.create_tab()
    Snacks.input({ prompt = "Tab name: " }, function(name)
        if name and name ~= "" then
            vim.cmd("tabnew")
            NVTabs.set_label({ icon = NVTabs.editor_icon, name = name })
        end
    end)
end

function fn.close_tab()
    local info = NVGit.get_worktree_info()

    if not info then
        if vim.fn.confirm("Close tab?", "&Yes\n&No", 2) == 1 then
            vim.cmd("tabclose")
        end
        return
    end

    Snacks.picker({
        title = "Close: " .. info.branch,
        items = {
            { text = "Delete branch and worktree", action = "delete-all" },
            { text = "Remove worktree", action = "delete-worktree" },
            { text = "Close tab", action = "close-tab" },
        },
        format = function(item)
            return { { " ", "SnacksPickerIcon" }, { item.text } }
        end,
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end

            if item.action == "close-tab" then
                vim.cmd("tabclose")
                return
            end

            -- Confirm before removing worktree with uncommitted changes
            local has_changes = NVGit.worktree_has_changes(info.path)
            if has_changes then
                if vim.fn.confirm("Worktree has uncommitted changes. Force remove?", "&Yes\n&No", 2) ~= 1 then
                    return
                end
            end

            vim.cmd("tabclose")
            vim.defer_fn(function()
                if not NVGit.remove_worktree(info.path, has_changes) then
                    vim.notify("Failed to remove worktree", vim.log.levels.ERROR)
                    return
                end
                vim.notify("Removed worktree: " .. info.path)

                if item.action == "delete-all" then
                    if not NVGit.delete_branch(info.branch) then
                        vim.notify("Failed to delete branch", vim.log.levels.ERROR)
                        return
                    end
                    vim.notify("Deleted branch: " .. info.branch)
                end
            end, 100)
        end,
        layout = { preset = "select" },
    })
end

function fn.open_worktree_tab(label, path)
    -- Get current file relative to git root
    local current_file = vim.fn.expand("%:p")
    local repo = NVGit.get_repo_info()
    local relative_path = nil
    if repo and current_file:find(repo.root, 1, true) == 1 then
        relative_path = current_file:sub(#repo.root + 2)
    end

    vim.cmd("tabnew")
    vim.cmd("tcd " .. vim.fn.fnameescape(path))
    NVTabs.set_label({ icon = "󰙅", name = label })

    -- Open same file in new worktree if it exists
    if relative_path then
        local new_file = path .. "/" .. relative_path
        if vim.fn.filereadable(new_file) == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(new_file))
        end
    end

    vim.notify("Worktree: " .. path)
end

function fn.create_worktree_from_name(name)
    local normalized = NVGit.normalize_worktree_name(name)
    if not normalized or normalized == "" then
        vim.notify("Invalid worktree name", vim.log.levels.ERROR)
        return
    end

    local repo = NVGit.get_repo_info()
    if not repo then
        vim.notify("Not in a git repository", vim.log.levels.ERROR)
        return
    end

    local worktree_path = repo.parent .. "/" .. repo.name .. "--" .. normalized

    local path, status = NVGit.create_worktree(normalized, worktree_path)
    if not path then
        vim.notify("Failed to create worktree", vim.log.levels.ERROR)
        return
    end

    -- Store original label in worktree config
    if status == "created" then
        NVGit.set_worktree_label(path, name)
    end

    -- Use stored label or fall back to input name
    local label = NVGit.get_worktree_label(path) or name
    fn.open_worktree_tab(label, path)
end

function fn.create_tab_with_worktree()
    Snacks.input({ prompt = "Worktree name: " }, function(name)
        if name and name ~= "" then
            fn.create_worktree_from_name(name)
        end
    end)
end

function fn.find_tab_with_cwd(path)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local tab_cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))
        if tab_cwd == path then
            return tab
        end
    end
    return nil
end

function fn.switch_to_worktree(worktree)
    local existing_tab = fn.find_tab_with_cwd(worktree.path)
    if existing_tab then
        vim.api.nvim_set_current_tabpage(existing_tab)
    else
        local label = NVGit.get_worktree_label(worktree.path) or worktree.branch
        fn.open_worktree_tab(label, worktree.path)
    end
end

function fn.pick_worktree()
    local worktrees = NVGit.get_all_worktrees()

    if #worktrees == 0 then
        vim.notify("No worktrees found", vim.log.levels.WARN)
        return
    end

    local current_cwd = vim.fn.getcwd(-1, 0)
    local items = {}
    local current_idx = 1
    for _, wt in ipairs(worktrees) do
        if not wt.bare then
            local label = NVGit.get_worktree_label(wt.path) or wt.branch
            table.insert(items, {
                text = label,
                path = wt.path,
                branch = wt.branch,
            })
            if wt.path == current_cwd then
                current_idx = #items
            end
        end
    end

    Snacks.picker({
        title = "Worktrees",
        items = items,
        matcher = { fuzzy = false, regex = true },
        on_show = function(picker)
            if current_idx > 1 then
                picker.list:move(current_idx, true)
            end
        end,
        format = function(item)
            local tab = fn.find_tab_with_cwd(item.path)
            return { { "󰙅 ", tab and "SnacksPickerIcon" or "Comment" }, { item.text } }
        end,
        confirm = function(picker, item)
            if item then
                picker:close()
                fn.switch_to_worktree(item)
            else
                local filter = picker.input:get()
                if filter and filter ~= "" then
                    picker:close()
                    fn.create_worktree_from_name(filter)
                end
            end
        end,
        preview = function(ctx)
            local lines = { "Path: " .. ctx.item.path, "Branch: " .. ctx.item.branch }
            ctx.preview:set_lines(lines)
        end,
    })
end

function NVTabs.set_label(label)
    vim.t.tab_label = label
    NVLualine.rename_tab(label.icon, label.name)
end

function NVTabs.set_label_if_empty(label)
    if not vim.t.tab_label then
        NVTabs.set_label(label)
    end
end

function NVTabs.save_labels()
    local cwd = vim.fn.getcwd(-1, 0) -- first tab cwd
    local tab_labels = {}

    for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local ok, tab_label = pcall(vim.api.nvim_tabpage_get_var, tab, "tab_label")
        if ok and tab_label then
            tab_labels[tostring(i)] = tab_label
        end
    end

    local all = vim.g.NVTABS or {}
    all[cwd] = not vim.tbl_isempty(tab_labels) and tab_labels or nil
    vim.g.NVTABS = all
end

function NVTabs.restore_labels()
    local cwd = vim.fn.getcwd(-1, 0) -- first tab cwd
    local all = vim.g.NVTABS or {}
    local tab_labels = all[cwd]

    if not tab_labels then
        return
    end

    NVTabs.restoring = true

    local tabs = vim.api.nvim_list_tabpages()
    local current_tab = vim.api.nvim_get_current_tabpage()

    for i, tab_label in pairs(tab_labels) do
        local tab = tabs[tonumber(i)]
        if tab and tab_label.icon and tab_label.name then
            vim.api.nvim_set_current_tabpage(tab)
            NVTabs.set_label(tab_label)
        end
    end

    vim.api.nvim_set_current_tabpage(current_tab)

    NVTabs.restoring = false
end

---@param tabid TabID
---@return boolean
function NVTabs.is_temporary(tabid)
    return NVFocus.is_focus_tab(tabid) or NVDiffview.is_diffview_tab(tabid) or NVClaudeCode.is_diff_tab(tabid)
end

---@return TabID[]
function NVTabs.get_non_temporary()
    local tabs = vim.api.nvim_list_tabpages()
    local result = {}

    for _, tabid in ipairs(tabs) do
        if not NVTabs.is_temporary(tabid) then
            table.insert(result, tabid)
        end
    end

    return result
end
