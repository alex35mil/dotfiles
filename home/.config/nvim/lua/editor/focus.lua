---@class FocusTab
---@field id TabID
---@field original_tab TabID
---@field original_win WinID
---@field created_at number

---@class NVFocus
---@field tab FocusTab?
NVFocus = { tab = nil }

function NVFocus.keymaps()
    K.map({ "<D-f>", "Toggle focus mode", NVFocus.toggle, mode = { "n", "i", "v", "t" } })
end

function NVFocus.autocmds()
    vim.api.nvim_create_autocmd("TabClosed", {
        desc = "Clear focus tab if closed",
        callback = function()
            if NVFocus.tab then
                local tabs = vim.api.nvim_list_tabpages()
                local focus_tab_exists = false
                for _, tab in ipairs(tabs) do
                    if tab == NVFocus.tab.id then
                        focus_tab_exists = true
                        break
                    end
                end

                if not focus_tab_exists then
                    NVFocus.tab = nil
                    log.trace({ "Focus tab was closed, cleared focus state" })
                end
            end
        end,
    })
end

function NVFocus.toggle()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_cursor = vim.api.nvim_win_get_cursor(0)

    log.trace({ "Toggling focus", state = NVFocus.tab })

    if NVFocus.tab then
        local current_tab = vim.api.nvim_get_current_tabpage()

        if NVFocus.tab.id ~= current_tab then
            log.trace({ "Focus tab exists but is not active. Activating it." })
            vim.api.nvim_set_current_tabpage(NVFocus.tab.id)
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(current_win, current_buf)
            vim.api.nvim_win_set_cursor(current_win, current_cursor)
        else
            log.trace({ "Focus tab is active. Deactivating it." })
            NVFocus.deactivate_active()
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

    NVFocus.tab = {
        id = focus_tab,
        original_tab = current_tab,
        original_win = current_win,
        created_at = os.time(),
    }
end

function NVFocus.ensure_deacitvated()
    if NVFocus.tab then
        local current_tab = vim.api.nvim_get_current_tabpage()

        if NVFocus.tab.id ~= current_tab then
            log.trace({ "Focus tab exists but is not active. Closing it." })
            local tab_number = vim.api.nvim_tabpage_get_number(NVFocus.tab.id)
            vim.cmd("tabclose " .. tab_number)
        else
            log.trace({ "Focus tab is active. Deactivating it." })
            NVFocus.deactivate_active()
        end
    end
end

function NVFocus.ensure_deactivated_if_active()
    if not NVFocus.tab then
        return false
    end

    local current_tab = vim.api.nvim_get_current_tabpage()

    if NVFocus.tab.id ~= current_tab then
        return false
    end

    log.trace({ "Focus tab is active. Deactivating it." })
    NVFocus.deactivate_active()

    return true
end

---@param tabid TabID
---@return boolean
function NVFocus.is_focus_tab(tabid)
    return NVFocus.tab ~= nil and NVFocus.tab.id == tabid
end

function NVFocus.deactivate_active()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local current_buf = vim.api.nvim_get_current_buf()

    local original_tab = NVFocus.tab.original_tab
    local original_win = NVFocus.tab.original_win
    local focus_tab_id = NVFocus.tab.id

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
