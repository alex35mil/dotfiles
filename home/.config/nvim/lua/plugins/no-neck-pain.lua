local fn = {}

NVNoNeckPain = {
    "shortcuts/no-neck-pain.nvim",
    opts = {
        width = NVWindows.default_width(),
        autocmds = {
            enableOnVimEnter = false,
            skipEnteringNoNeckPainBuffer = true,
        },
    },
}

function NVNoNeckPain.increase_window_width()
    vim.cmd("NoNeckPainWidthUp")
end

function NVNoNeckPain.decrease_window_width()
    vim.cmd("NoNeckPainWidthDown")
end

function NVNoNeckPain.set_default_window_width()
    vim.cmd("NoNeckPainResize " .. NVWindows.default_width())
end

---@return {left: WinID, right: WinID}?
function NVNoNeckPain.get_sidepads()
    local plugin = _G.NoNeckPain

    if not plugin then
        return nil
    end

    local state = plugin.state

    if not state then
        return nil
    end

    local current_tab = vim.api.nvim_get_current_tabpage()

    local tab = nil

    if state.tabs ~= nil then
        for _, t in ipairs(state.tabs) do
            if t.id == current_tab then
                tab = t
                break
            end
        end
    end

    if not tab then
        return nil
    end

    local win = tab.wins.main

    return {
        left = win.left,
        right = win.right,
    }
end

---@return boolean
function NVNoNeckPain.are_sidepads_visible()
    local sidepads = NVNoNeckPain.get_sidepads()

    if not sidepads then
        return false
    end

    return sidepads.left ~= nil or sidepads.right ~= nil
end

function NVNoNeckPain.ensure_sidepads_hidden()
    if NVNoNeckPain.are_sidepads_visible() then
        vim.cmd("NoNeckPain")
    end
end

function NVNoNeckPain.disable()
    fn.ensure_cursor_position(NoNeckPain.disable)
end

function NVNoNeckPain.enable()
    fn.ensure_cursor_position(NoNeckPain.enable)
end

---@param f function
---@param opts {check_sidepads_visibility: boolean}?
function NVNoNeckPain.update_layout_with(f, opts)
    local config = vim.tbl_extend("keep", opts or {}, {
        check_sidepads_visibility = true,
    })

    local sidepads_visible

    if config.check_sidepads_visibility then
        sidepads_visible = NVNoNeckPain.are_sidepads_visible()
    else
        sidepads_visible = true
    end

    if sidepads_visible then
        NVNoNeckPain.disable()
    end

    f()

    if sidepads_visible then
        NVNoNeckPain.enable()
    end
end

function NVNoNeckPain.reload()
    fn.ensure_cursor_position(function()
        pcall(NoNeckPain.disable)
        NoNeckPain.enable()
    end)
end

---@param f function
function fn.ensure_cursor_position(f)
    local current_cursor = NVCursor.get()

    f()

    -- NoNeckPain moves cursor on activation
    -- and it debounces execution by 10ms
    -- Can be removed if addressed: https://github.com/shortcuts/no-neck-pain.nvim/issues/480
    vim.defer_fn(function()
        pcall(NVCursor.set, current_cursor)
    end, 15)
end

return { NVNoNeckPain }
