---@class FocusTab
---@field tab TabID
---@field created_at number

---@class NVTabs
---@field focus FocusTab?
NVTabs = { focus = nil }

local fn = {}

function NVTabs.keymaps()
    K.map({ NVKeyRemaps["<D-m>"], "Toggle focus mode", fn.toggle_focus, mode = { "n", "i", "v" } })
end

function NVTabs.autocmds()
    vim.api.nvim_create_autocmd("TabClosed", {
        callback = function()
            if NVTabs.focus then
                local tabs = vim.api.nvim_list_tabpages()
                local focus_tab_exists = false
                for _, tab in ipairs(tabs) do
                    if tab == NVTabs.focus.tab then
                        focus_tab_exists = true
                        break
                    end
                end

                if not focus_tab_exists then
                    NVTabs.focus = nil
                    log.trace({ "Focus tab was closed, cleared focus state" })
                end
            end
        end,
        desc = "Clear focus tab if closed",
    })
end

function fn.toggle_focus()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_cursor = vim.api.nvim_win_get_cursor(0)

    log.trace({ "Toggling focus", state = NVTabs.focus })

    if NVTabs.focus then
        local current_tab = vim.api.nvim_get_current_tabpage()

        if NVTabs.focus.tab ~= current_tab then
            log.trace({ "Focus tab exists but is not active. Activating it." })
            vim.api.nvim_set_current_tabpage(NVTabs.focus.tab)
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(current_win, current_buf)
            vim.api.nvim_win_set_cursor(current_win, current_cursor)
        else
            log.trace({ "Focus tab is active. Deactivating it." })
            fn.deactivate_active_focus()
        end
        return
    end

    log.trace({ "No focus tab found. Creating one." })

    vim.cmd("tabnew")
    NVLualine.rename_tab("focus")

    local focus_tab = vim.api.nvim_get_current_tabpage()
    local current_win = vim.api.nvim_get_current_win()
    local empty_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_buf(current_win, current_buf)
    vim.api.nvim_win_set_cursor(current_win, current_cursor)
    vim.api.nvim_buf_delete(empty_buf, { force = true })
    vim.schedule(NVNoNeckPain.enable)

    NVTabs.focus = {
        tab = focus_tab,
        created_at = os.time(),
    }
end

function NVTabs.ensure_focus_deacitvated()
    if NVTabs.focus then
        local current_tab = vim.api.nvim_get_current_tabpage()

        if NVTabs.focus.tab ~= current_tab then
            log.trace({ "Focus tab exists but is not active. Closing it." })
            local tab_number = vim.api.nvim_tabpage_get_number(NVTabs.focus.tab)
            vim.cmd("tabclose " .. tab_number)
        else
            log.trace({ "Focus tab is active. Deactivating it." })
            fn.deactivate_active_focus()
        end
    end
end

function NVTabs.ensure_focus_deactivated_if_active()
    if not NVTabs.focus then
        return false
    end

    local current_tab = vim.api.nvim_get_current_tabpage()

    if NVTabs.focus.tab ~= current_tab then
        return false
    end

    log.trace({ "Focus tab is active. Deactivating it." })
    fn.deactivate_active_focus()

    return true
end

function fn.deactivate_active_focus()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local current_buf = vim.api.nvim_get_current_buf()
    local tab_number = vim.api.nvim_tabpage_get_number(NVTabs.focus.tab)
    vim.cmd("tabclose " .. tab_number)

    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(current_win, current_buf)
    vim.api.nvim_win_set_cursor(current_win, current_cursor)
end
