---@class FocusTab
---@field id TabID
---@field original_tab TabID
---@field original_win WinID
---@field created_at number

---@class NVFocus
---@field tab FocusTab?
NVFocusMode = { tab = nil }

function NVFocusMode.keymaps()
    K.map({ "<D-f>", "Toggle focus mode", NVFocusMode.toggle, mode = { "n", "i", "v", "t" } })
end

function NVFocusMode.autocmds()
    vim.api.nvim_create_autocmd("TabClosed", {
        desc = "Clear focus tab if closed",
        callback = function()
            if NVFocusMode.tab then
                local tabs = vim.api.nvim_list_tabpages()
                local focus_tab_exists = false
                for _, tab in ipairs(tabs) do
                    if tab == NVFocusMode.tab.id then
                        focus_tab_exists = true
                        break
                    end
                end

                if not focus_tab_exists then
                    NVFocusMode.tab = nil
                    log.trace({ "Focus tab was closed, cleared focus state" })
                end
            end
        end,
    })
end

function NVFocusMode.toggle()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_cursor = vim.api.nvim_win_get_cursor(0)

    log.trace({ "Toggling focus", state = NVFocusMode.tab })

    if NVFocusMode.tab then
        local current_tab = vim.api.nvim_get_current_tabpage()

        if NVFocusMode.tab.id ~= current_tab then
            log.trace({ "Focus tab exists but is not active. Activating it." })
            vim.api.nvim_set_current_tabpage(NVFocusMode.tab.id)
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(current_win, current_buf)
            vim.api.nvim_win_set_cursor(current_win, current_cursor)
        else
            log.trace({ "Focus tab is active. Deactivating it." })
            NVFocusMode.deactivate_active()
        end
        return
    end

    log.trace({ "No focus tab found. Creating one." })

    local current_tab = vim.api.nvim_get_current_tabpage()
    local current_win = vim.api.nvim_get_current_win()

    vim.cmd("tabnew")
    NVTabs.set_label({ icon = "󰋱", name = "focus" })

    local focus_tab = vim.api.nvim_get_current_tabpage()
    local focus_win = vim.api.nvim_get_current_win()
    local empty_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_buf(focus_win, current_buf)
    vim.api.nvim_win_set_cursor(focus_win, current_cursor)
    vim.api.nvim_buf_delete(empty_buf, { force = true })

    NVFocusMode.tab = {
        id = focus_tab,
        original_tab = current_tab,
        original_win = current_win,
        created_at = os.time(),
    }
end

function NVFocusMode.ensure_deacitvated()
    if NVFocusMode.tab then
        local current_tab = vim.api.nvim_get_current_tabpage()

        if NVFocusMode.tab.id ~= current_tab then
            log.trace({ "Focus tab exists but is not active. Closing it." })
            local tab_number = vim.api.nvim_tabpage_get_number(NVFocusMode.tab.id)
            vim.cmd("tabclose " .. tab_number)
        else
            log.trace({ "Focus tab is active. Deactivating it." })
            NVFocusMode.deactivate_active()
        end
    end
end

function NVFocusMode.ensure_deactivated_if_active()
    if not NVFocusMode.tab then
        return false
    end

    local current_tab = vim.api.nvim_get_current_tabpage()

    if NVFocusMode.tab.id ~= current_tab then
        return false
    end

    log.trace({ "Focus tab is active. Deactivating it." })
    NVFocusMode.deactivate_active()

    return true
end

---@param tabid TabID
---@return boolean
function NVFocusMode.is_focus_tab(tabid)
    return NVFocusMode.tab ~= nil and NVFocusMode.tab.id == tabid
end

function NVFocusMode.deactivate_active()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local current_buf = vim.api.nvim_get_current_buf()

    local original_tab = NVFocusMode.tab.original_tab
    local original_win = NVFocusMode.tab.original_win
    local focus_tab_id = NVFocusMode.tab.id

    -- Check if original tab still exists
    local original_tab_valid = false
    local tabs = vim.api.nvim_list_tabpages()
    for _, tab in ipairs(tabs) do
        if tab == original_tab then
            original_tab_valid = true
            break
        end
    end

    -- Check if original window still exists
    local original_win_valid = original_tab_valid and vim.api.nvim_win_is_valid(original_win)

    if original_tab_valid then
        vim.api.nvim_set_current_tabpage(original_tab)
        if original_win_valid then
            vim.api.nvim_set_current_win(original_win)
        end
    end

    local focus_tab_number = vim.api.nvim_tabpage_get_number(focus_tab_id)
    vim.cmd("tabclose " .. focus_tab_number)

    -- Restore buffer and cursor in current window
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(current_win, current_buf)
    vim.api.nvim_win_set_cursor(current_win, current_cursor)
end
