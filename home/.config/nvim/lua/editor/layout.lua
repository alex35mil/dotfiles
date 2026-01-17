NVLayout = {}

---@class TabState
---@field on boolean
---@field content_width number | nil
---@field sidepads {left: WinID | nil, right: WinID | nil}

local State = {
    on = false, ---@type boolean
    creating = false, ---@type boolean
    tabs = {}, ---@type table<TabID, TabState>
}

local WIDTH_STEP = 5

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
    return tab.content_width or NVWindows.default_width()
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
    if tab.sidepads.left and vim.api.nvim_win_is_valid(tab.sidepads.left) then
        vim.api.nvim_win_close(tab.sidepads.left, true)
    end
    if tab.sidepads.right and vim.api.nvim_win_is_valid(tab.sidepads.right) then
        vim.api.nvim_win_close(tab.sidepads.right, true)
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

local function create_sidepads()
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

---@return boolean
local function has_sidepads()
    local tab = get_tab_state()
    return tab.sidepads.left ~= nil and vim.api.nvim_win_is_valid(tab.sidepads.left)
end

local function adjust_sidepads()
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

local function update_layout()
    if not State.on then
        return
    end
    local tab = get_tab_state()
    if not tab.on then
        return
    end

    if has_multi_column_row() then
        local had_sidepads = has_sidepads()
        if had_sidepads then
            delete_sidepads()
            vim.cmd("wincmd =")
        end
    else
        local total = vim.o.columns
        local content_width = get_content_width()

        if total > content_width then
            if has_sidepads() then
                adjust_sidepads()
            else
                create_sidepads()
            end
        else
            delete_sidepads()
        end
    end
end

function NVLayout.autocmds()
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
                vim.cmd("wincmd p")
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
        callback = function(args)
            local tab_id = tonumber(args.file)
            if tab_id and State.tabs[tab_id] then
                State.tabs[tab_id] = nil
            end
        end,
    })
end

function NVLayout.enable()
    State.on = true
    local tab = get_tab_state()
    tab.on = true
    vim.schedule(update_layout)
end

function NVLayout.disable()
    local tab = get_tab_state()
    tab.on = false
    vim.schedule(delete_sidepads)
end

---@param buf BufID
---@return boolean
function NVLayout.is_sidepad_buf(buf)
    return is_sidepad_buf(buf)
end

---@param win WinID
---@return boolean
function NVLayout.is_sidepad_win(win)
    return is_sidepad_win(win)
end

---@return boolean
function NVLayout.is_padded()
    return has_sidepads()
end

---@return boolean
function NVLayout.is_managed()
    local tab = get_tab_state()
    return State.on and tab.on and not has_multi_column_row()
end

---@param amount number | nil
function NVLayout.increase_width(amount)
    local tab = get_tab_state()
    amount = amount or WIDTH_STEP
    local current = get_content_width()
    local max_width = vim.o.columns
    tab.content_width = math.min(max_width, current + amount)
    vim.schedule(update_layout)
end

---@param amount number | nil
function NVLayout.decrease_width(amount)
    local tab = get_tab_state()
    amount = amount or WIDTH_STEP
    local current = math.min(get_content_width(), vim.o.columns)
    local min_width = 40
    tab.content_width = math.max(min_width, current - amount)
    vim.schedule(update_layout)
end

function NVLayout.reset_width()
    local tab = get_tab_state()
    tab.content_width = nil
    vim.schedule(update_layout)
end
