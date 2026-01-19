-- Layout manager that positions content using invisible sidepad windows.
-- Sidepads are empty, non-focusable buffers that push content to the desired width.
--
-- Two layout modes:
--   1. Centered: symmetric sidepads on both sides, content centered.
--      Applies when: at most one window per row.
--   2. Companion: left sidepad only, with one main buffer centered and a fixed-width panel (e.g., AI chat) on the right.
--      Applies when: exactly one main content column + one fixed-width companion column.

NVLayoutManager = {}

---@class TabState
---@field on boolean
---@field content_width number | nil
---@field sidepads {left: WinID | nil, right: WinID | nil}

local State = {
    on = false, ---@type boolean
    creating = false, ---@type boolean
    tabs = {}, ---@type table<TabID, TabState>
}

function NVLayoutManager.default_width()
    return NVScreen.is_large() and 140 or 120
end

local WIDTH_CHANGE_STEP = 5
local MIN_WIDTH = 40

---@param tab_id? TabID
---@return TabState
local function get_tab_state(tab_id)
    tab_id = tab_id or vim.api.nvim_get_current_tabpage()
    if not State.tabs[tab_id] then
        State.tabs[tab_id] = {
            on = false,
            content_width = nil,
            sidepads = { left = nil, right = nil },
        }
    end
    return State.tabs[tab_id]
end

local function get_content_width()
    local tab = get_tab_state()
    return tab.content_width or NVLayoutManager.default_width()
end

local function is_sidepad_buf(buf)
    return vim.b[buf].sidepad == true
end

local function is_sidepad_win(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    return is_sidepad_buf(vim.api.nvim_win_get_buf(win))
end

local function delete_sidepads()
    local tab = get_tab_state()
    -- Only close if window is valid AND is actually a sidepad
    if tab.sidepads.left and vim.api.nvim_win_is_valid(tab.sidepads.left) then
        if is_sidepad_win(tab.sidepads.left) then
            vim.api.nvim_win_close(tab.sidepads.left, true)
        end
    end
    if tab.sidepads.right and vim.api.nvim_win_is_valid(tab.sidepads.right) then
        if is_sidepad_win(tab.sidepads.right) then
            vim.api.nvim_win_close(tab.sidepads.right, true)
        end
    end
    tab.sidepads.left = nil
    tab.sidepads.right = nil
end

local function create_sidepad_buf()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.b[buf].sidepad = true
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    return buf
end

local function setup_sidepad_win(win)
    vim.wo[win].winfixwidth = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].statuscolumn = ""
    vim.wo[win].signcolumn = "no"
    vim.wo[win].cursorline = false
    vim.wo[win].cursorcolumn = false
end

local function create_sidepads_for_centered_layout()
    local tab = get_tab_state()
    local content_width = get_content_width()
    local total = vim.o.columns

    if total <= content_width then
        return
    end

    State.creating = true

    local padding = math.floor((total - content_width) / 2)
    local original_win = vim.api.nvim_get_current_win()

    -- Create left sidepad at absolute left edge
    vim.cmd("topleft vnew")
    local temp_buf = vim.api.nvim_get_current_buf()
    tab.sidepads.left = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(tab.sidepads.left, create_sidepad_buf())
    vim.api.nvim_buf_delete(temp_buf, { force = true })
    vim.api.nvim_win_set_width(tab.sidepads.left, padding)
    setup_sidepad_win(tab.sidepads.left)

    -- Create right sidepad at absolute right edge
    vim.cmd("botright vnew")
    temp_buf = vim.api.nvim_get_current_buf()
    tab.sidepads.right = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(tab.sidepads.right, create_sidepad_buf())
    vim.api.nvim_buf_delete(temp_buf, { force = true })
    vim.api.nvim_win_set_width(tab.sidepads.right, padding)
    setup_sidepad_win(tab.sidepads.right)

    vim.api.nvim_set_current_win(original_win)

    State.creating = false
end

---@param companion_width number
local function create_sidepad_for_companion_layout(companion_width)
    local tab = get_tab_state()
    local content_width = get_content_width()
    local total = vim.o.columns

    local padding = total - content_width - companion_width - 1
    if padding <= 0 then
        return
    end

    State.creating = true
    local original_win = vim.api.nvim_get_current_win()

    vim.cmd("topleft vnew")
    local temp_buf = vim.api.nvim_get_current_buf()
    tab.sidepads.left = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(tab.sidepads.left, create_sidepad_buf())
    vim.api.nvim_buf_delete(temp_buf, { force = true })
    vim.api.nvim_win_set_width(tab.sidepads.left, padding)
    setup_sidepad_win(tab.sidepads.left)

    vim.api.nvim_set_current_win(original_win)
    State.creating = false
end

---@param companion_width number
local function adjust_sidepad_for_companion_layout(companion_width)
    local tab = get_tab_state()
    local content_width = get_content_width()
    local total = vim.o.columns
    local padding = total - content_width - companion_width - 1

    if padding <= 0 then
        delete_sidepads()
        return
    end

    if tab.sidepads.left and vim.api.nvim_win_is_valid(tab.sidepads.left) then
        vim.api.nvim_win_set_width(tab.sidepads.left, padding)
    end
end

local function has_multi_column_row(node)
    node = node or vim.fn.winlayout()

    if node[1] == "leaf" then
        return false
    elseif node[1] == "row" then
        -- Count content windows in this row
        local count = 0
        for _, child in ipairs(node[2]) do
            if child[1] == "leaf" then
                if not is_sidepad_win(child[2]) then
                    count = count + 1
                end
            else
                -- Nested layout counts as 1 column
                count = count + 1
            end
        end
        if count > 1 then
            return true
        end
        -- Check children recursively
        for _, child in ipairs(node[2]) do
            if has_multi_column_row(child) then
                return true
            end
        end
        return false
    elseif node[1] == "col" then
        -- Check children recursively
        for _, child in ipairs(node[2]) do
            if has_multi_column_row(child) then
                return true
            end
        end
        return false
    end

    return false
end

---@return {content_wins: WinID[], companion_wins: WinID[], companion_width: number, has_companion_window: boolean} | nil
local function get_companion_layout_info()
    local layout = vim.fn.winlayout()
    if layout[1] ~= "row" then
        return nil
    end

    local children = layout[2]
    -- Filter out sidepads, collect content columns
    local columns = {}
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, child in ipairs(children) do
        if child[1] == "leaf" then
            if not is_sidepad_win(child[2]) then
                table.insert(columns, child)
            end
        else
            table.insert(columns, child) -- col or nested row
        end
    end

    if #columns ~= 2 then
        return nil
    end

    -- Get windows from each column
    local function get_wins(node)
        if node[1] == "leaf" then
            return { node[2] }
        end
        if node[1] == "col" then
            local wins = {}
            ---@diagnostic disable-next-line: param-type-mismatch
            for _, c in ipairs(node[2]) do
                ---@diagnostic disable-next-line: param-type-mismatch
                vim.list_extend(wins, get_wins(c))
            end
            return wins
        end
        return nil
    end

    local content_wins = get_wins(columns[1])
    local companion_wins = get_wins(columns[2])
    if not content_wins or not companion_wins then
        return nil
    end

    -- Calculate companion column width and check for fixed-width window
    local companion_width = 0
    local has_companion_window = false
    for _, win in ipairs(companion_wins) do
        companion_width = math.max(companion_width, vim.api.nvim_win_get_width(win))
        if vim.wo[win].winfixwidth then
            has_companion_window = true
        end
    end

    return {
        content_wins = content_wins,
        companion_wins = companion_wins,
        companion_width = companion_width,
        has_companion_window = has_companion_window,
    }
end

---@return boolean
local function has_any_sidepad()
    local tab = get_tab_state()
    -- Check both window validity AND that it still displays a sidepad buffer
    local has_left = tab.sidepads.left ~= nil and is_sidepad_win(tab.sidepads.left)
    local has_right = tab.sidepads.right ~= nil and is_sidepad_win(tab.sidepads.right)
    return has_left or has_right
end

---@return boolean
local function has_sidepads_for_centered_layout()
    local tab = get_tab_state()
    -- Check both window validity AND that it still displays a sidepad buffer
    local has_left = tab.sidepads.left ~= nil and is_sidepad_win(tab.sidepads.left)
    local has_right = tab.sidepads.right ~= nil and is_sidepad_win(tab.sidepads.right)
    return has_left and has_right
end

local function adjust_sidepads_for_centered_layout()
    local tab = get_tab_state()
    local content_width = get_content_width()
    local total = vim.o.columns
    local padding = math.floor((total - content_width) / 2)

    if tab.sidepads.left and vim.api.nvim_win_is_valid(tab.sidepads.left) then
        vim.api.nvim_win_set_width(tab.sidepads.left, padding)
    end
    if tab.sidepads.right and vim.api.nvim_win_is_valid(tab.sidepads.right) then
        vim.api.nvim_win_set_width(tab.sidepads.right, padding)
    end
end

---@return boolean
local function is_managed()
    local tab = get_tab_state()
    if not State.on or not tab.on then
        return false
    end

    -- Companion layout is also managed
    local companion = get_companion_layout_info()
    if companion and companion.has_companion_window then
        return true
    end

    return not has_multi_column_row()
end

local function is_in_companion_panel()
    local companion = get_companion_layout_info()
    if not companion or not companion.has_companion_window then
        return false
    end

    local current_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(companion.companion_wins) do
        if win == current_win then
            return true
        end
    end

    return false
end

local function update_layout()
    if not State.on then
        return
    end
    if State.creating then
        return
    end
    local tab = get_tab_state()
    if not tab.on then
        return
    end

    -- Check for companion layout (main content + fixed-width companion panel on right)
    local companion = get_companion_layout_info()
    if companion and companion.has_companion_window then
        local total = vim.o.columns
        local content_width = get_content_width()
        local needed = content_width + companion.companion_width + 1

        if total > needed then
            local has_left = tab.sidepads.left and vim.api.nvim_win_is_valid(tab.sidepads.left)
            local has_right = tab.sidepads.right and vim.api.nvim_win_is_valid(tab.sidepads.right)

            if has_left and not has_right then
                -- Already in companion layout, just adjust sidepad
                adjust_sidepad_for_companion_layout(companion.companion_width)
            else
                -- Transitioning from centered or unmanaged layout
                delete_sidepads()
                create_sidepad_for_companion_layout(companion.companion_width)
            end
            return
        end
    end

    if has_multi_column_row() then
        if has_any_sidepad() then
            delete_sidepads()
            vim.cmd("wincmd =")
        end
    else
        local total = vim.o.columns
        local content_width = get_content_width()

        if total > content_width then
            if has_sidepads_for_centered_layout() then
                adjust_sidepads_for_centered_layout()
            else
                delete_sidepads()
                create_sidepads_for_centered_layout()
            end
        else
            delete_sidepads()
        end
    end
end

function NVLayoutManager.autocmds()
    local group = vim.api.nvim_create_augroup("NVLayout", { clear = true })

    vim.api.nvim_create_autocmd("WinResized", {
        group = group,
        callback = function()
            vim.schedule(update_layout)
        end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function()
            if State.creating then
                return
            end
            local win = vim.api.nvim_get_current_win()
            if is_sidepad_win(win) then
                -- Try wincmd p first (goes to previous window)
                vim.cmd("wincmd p")

                -- If still on a sidepad, wincmd p failed (previous window was closed)
                -- Fall back to finding any non-sidepad window
                if is_sidepad_win(vim.api.nvim_get_current_win()) then
                    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                        if not is_sidepad_win(w) then
                            vim.api.nvim_set_current_win(w)
                            return
                        end
                    end
                end
            end
        end,
    })

    vim.api.nvim_create_autocmd("TabEnter", {
        group = group,
        callback = function()
            if not State.on then
                return
            end
            local tab = get_tab_state()
            tab.on = true
            vim.schedule(update_layout)
        end,
    })

    vim.api.nvim_create_autocmd("TabClosed", {
        group = group,
        callback = function()
            -- Clean up state for any tabpages that no longer exist
            -- Note: args.file is tab NUMBER (position), not tabpage HANDLE
            for tab_id, _ in pairs(State.tabs) do
                if not vim.api.nvim_tabpage_is_valid(tab_id) then
                    State.tabs[tab_id] = nil
                end
            end
        end,
    })
end

function NVLayoutManager.enable()
    State.on = true
    local tab = get_tab_state()
    tab.on = true
    vim.schedule(update_layout)
end

function NVLayoutManager.disable()
    local tab = get_tab_state()
    tab.on = false
    vim.schedule(delete_sidepads)
end

---@param buf BufID
---@return boolean
function NVLayoutManager.is_sidepad_buf(buf)
    return is_sidepad_buf(buf)
end

---@param win WinID
---@return boolean
function NVLayoutManager.is_sidepad_win(win)
    return is_sidepad_win(win)
end

---@param amount number | nil
function NVLayoutManager.increase_width(amount)
    amount = amount or WIDTH_CHANGE_STEP

    -- Companion panel or unmanaged layout: resize directly
    if is_in_companion_panel() or not is_managed() then
        vim.cmd("vertical resize +" .. amount)
        return
    end

    local tab = get_tab_state()
    local current = get_content_width()
    local max_width = vim.o.columns
    tab.content_width = math.min(max_width, current + amount)
    vim.schedule(update_layout)
end

---@param amount number | nil
function NVLayoutManager.decrease_width(amount)
    amount = amount or WIDTH_CHANGE_STEP

    -- Companion panel or unmanaged layout: resize directly
    if is_in_companion_panel() or not is_managed() then
        vim.cmd("vertical resize -" .. amount)
        return
    end

    local tab = get_tab_state()
    local current = math.min(get_content_width(), vim.o.columns)
    tab.content_width = math.max(MIN_WIDTH, current - amount)
    vim.schedule(update_layout)
end

function NVLayoutManager.reset_width()
    local tab = get_tab_state()
    tab.content_width = nil
    vim.schedule(update_layout)
end
