---@class FocusTab
---@field id TabID
---@field created_at number

---@class NVFocus
---@field tab FocusTab?
NVFocus = { tab = nil }

function NVFocus.keymaps()
    K.map({ "<D-f>", "Toggle focus mode", NVFocus.toggle, mode = { "n", "i", "v", "t" } })
end

function NVFocus.autocmds()
    vim.api.nvim_create_autocmd("TabClosed", {
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
        desc = "Clear focus tab if closed",
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

    vim.cmd("tabnew")
    NVTabs.set_label({ icon = "󰋱", name = "focus" })

    local focus_tab = vim.api.nvim_get_current_tabpage()
    local current_win = vim.api.nvim_get_current_win()
    local empty_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_buf(current_win, current_buf)
    vim.api.nvim_win_set_cursor(current_win, current_cursor)
    vim.api.nvim_buf_delete(empty_buf, { force = true })
    vim.schedule(NVNoNeckPain.enable)

    NVFocus.tab = {
        id = focus_tab,
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

function NVFocus.deactivate_active()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local current_buf = vim.api.nvim_get_current_buf()
    local tab_number = vim.api.nvim_tabpage_get_number(NVFocus.tab.id)
    vim.cmd("tabclose " .. tab_number)

    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(current_win, current_buf)
    vim.api.nvim_win_set_cursor(current_win, current_cursor)
end
