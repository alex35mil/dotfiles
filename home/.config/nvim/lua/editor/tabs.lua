---@class TabLabel
---@field icon string
---@field name string

NVTabs = {
    editor_icon = "",
}

local fn = {}

function NVTabs.keymaps()
    K.map({ "<D-S-m>", "Make new tab", fn.create_tab, mode = { "n", "i", "v", "t" } })
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

    NVGitWorktrees.close_tab(info)
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
    return NVFocusMode.is_focus_tab(tabid) or NVDiffview.is_diffview_tab(tabid) or NVClaudeCode.is_diff_tab(tabid)
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
