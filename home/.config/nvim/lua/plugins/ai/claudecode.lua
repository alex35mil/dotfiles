local fn = {}

local CCProvider = require("editor.claudecode").init({
    layout = {
        default = "side",
        side = {
            position = "right",
            width = 0.3,
        },
        float = {
            width = 0.6,
            height = 0.8,
            backdrop = false,
            border = "rounded",
        },
        common = {
            wo = {
                winbar = "",
                winhighlight = "Normal:SnacksTerminal,FloatBorder:SnacksTerminalFloatBorder,WinBar:SnacksTerminalHeader,WinBarNC:SnacksTerminalHeaderNC",
            },
            keys = {
                claude_new_line = {
                    "<S-CR>",
                    function()
                        fn.new_line()
                    end,
                    mode = "t",
                    desc = "New line",
                },
                claude_hide = {
                    NVKeymaps.close,
                    function(self)
                        self:hide()
                    end,
                    mode = "t",
                    desc = "Hide",
                },
            },
        },
    },
})

NVClaudeCode = {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    keys = function()
        return {
            {
                "<D-S-c>",
                function()
                    CCProvider.open_on_side()
                end,
                mode = { "n", "i", "t", "v" },
                desc = "Toggle Claude in a side panel",
            },
            {
                "<D-S-g>",
                function()
                    CCProvider.open_float()
                end,
                mode = { "n", "i", "t", "v" },
                desc = "Toggle Claude in float window",
            },
            {
                "<C-S-c>",
                function()
                    CCProvider.open_on_side("continue")
                end,
                mode = { "n", "i", "t", "v" },
                desc = "Continue last session in side panel",
            },
            {
                "<C-S-g>",
                function()
                    CCProvider.open_float("continue")
                end,
                mode = { "n", "i", "t", "v" },
                desc = "Continue last session in float window",
            },
            {
                "<M-S-c>",
                function()
                    CCProvider.open_on_side("resume")
                end,
                mode = { "n", "i", "t", "v" },
                desc = "Resume session in side panel",
            },
            {
                "<M-S-g>",
                function()
                    CCProvider.open_float("resume")
                end,
                mode = { "n", "i", "t", "v" },
                desc = "Resume session in float window",
            },
            { "<D-p>", fn.post_and_focus, mode = { "n", "i", "v" }, desc = "Post to Claude and focus" },
            { "<C-CR>", fn.accept_diff, mode = { "n", "i", "v" }, desc = "Accept Claude diff" },
            { NVKeyRemaps["<C-c>"], fn.reject_diff, mode = { "n", "i", "v" }, desc = "Reject Claude diff" },
            {
                "<M-c>",
                CCProvider.toggle_layout,
                mode = { "n", "i", "t", "v" },
                desc = "Toggle Claude layout (side/float)",
            },
        }
    end,
    opts = {
        terminal = {
            provider = CCProvider,
        },
        diff_opts = {
            layout = "vertical",
            open_in_new_tab = true,
            keep_terminal_focus = false,
            hide_terminal_in_new_tab = true,
            on_new_file_reject = "close_window",
        },
    },
}

---@return boolean
function NVClaudeCode.hide_active()
    if fn.is_claude_active() then
        CCProvider.close()
        return true
    end
    return false
end

---@param bufid BufID | nil
---@return boolean
function NVClaudeCode.is_diff_active(bufid)
    bufid = bufid or vim.api.nvim_get_current_buf()
    return vim.b[bufid].claudecode_diff_tab_name ~= nil
end

---@param tabid TabID
---@return boolean
function NVClaudeCode.is_diff_tab(tabid)
    local tab_wins = vim.api.nvim_tabpage_list_wins(tabid)
    for _, win in ipairs(tab_wins) do
        local bufid = vim.api.nvim_win_get_buf(win)
        if vim.b[bufid].claudecode_diff_tab_name ~= nil then
            return true
        end
    end
    return false
end

function fn.accept_diff()
    if NVClaudeCode.is_diff_active() then
        -- Sometimes, when I accept/reject a diff while there's a diffview tab open elsewhere,
        -- the diffview tab gets closed and its windows get merged into the tab where the Claude Code terminal is.
        -- I couldn't find the culprit, so I just preemptively close all diff tabs since it's harmless.
        NVDiffview.ensure_all_hidden()

        vim.cmd("ClaudeCodeDiffAccept")
        vim.defer_fn(CCProvider.focus, 50)
    end
end

function fn.reject_diff()
    if NVClaudeCode.is_diff_active() then
        -- Sometimes, when I accept/reject a diff while there's a diffview tab open elsewhere,
        -- the diffview tab gets closed and its windows get merged into the tab where the Claude Code terminal is.
        -- I couldn't find the culprit, so I just preemptively close all diff tabs since it's harmless.
        NVDiffview.ensure_all_hidden()

        vim.cmd("ClaudeCodeDiffDeny")
        vim.defer_fn(CCProvider.focus, 50)
    end
end

function fn.new_line()
    vim.api.nvim_feedkeys("\\", "t", true)
    vim.defer_fn(function()
        vim.api.nvim_feedkeys("\r", "t", true)
    end, 10)
end

function fn.post_and_focus()
    local is_visible = fn.is_claude_visible()

    if is_visible then
        local mode = vim.fn.mode()

        if mode == "v" or mode == "V" then
            vim.cmd("ClaudeCodeSend")
            vim.defer_fn(function()
                vim.cmd("ClaudeCodeFocus")
            end, 10)
        else
            vim.cmd("ClaudeCodeAdd %")
            vim.cmd("ClaudeCodeFocus")
        end
    else
        local function save_state()
            local mode = vim.fn.mode()
            local pos = vim.fn.getpos(".")
            local buf = vim.api.nvim_get_current_buf()
            local win = vim.api.nvim_get_current_win()
            local selection = nil

            if mode == "v" or mode == "V" then
                selection = {
                    start_pos = vim.fn.getpos("'<"),
                    end_pos = vim.fn.getpos("'>"),
                    mode = mode,
                }
            end

            return {
                pos = pos,
                buf = buf,
                win = win,
                selection = selection,
                mode = mode,
            }
        end

        local function restore_state(state)
            if vim.api.nvim_buf_is_valid(state.buf) and vim.api.nvim_win_is_valid(state.win) then
                vim.api.nvim_win_set_buf(state.win, state.buf)
                vim.api.nvim_set_current_win(state.win)
                vim.fn.setpos(".", state.pos)

                if state.selection then
                    vim.fn.setpos("'<", state.selection.start_pos)
                    vim.fn.setpos("'>", state.selection.end_pos)
                end
            end
        end

        local was_claude_initially_connected = fn.is_claude_connected()

        local saved_state = save_state()

        if saved_state.selection ~= nil then
            NVKeys.send("<Esc>", { mode = "x" })
        end

        vim.cmd("ClaudeCode")

        local function wait_for_claude_connection(callback)
            local start_time = vim.uv.hrtime()
            local timeout_ns = 10 * 1000 * 1000 * 1000 -- 10 seconds in nanoseconds
            local check_interval = 100 -- milliseconds

            local function check_connection()
                local elapsed = vim.uv.hrtime() - start_time

                if fn.is_claude_connected() then
                    if was_claude_initially_connected then
                        vim.defer_fn(callback, 100)
                    else
                        vim.defer_fn(callback, 500) -- no idea why it needs extended delay but it's needed
                    end
                    return
                end

                if elapsed > timeout_ns then
                    log.error("Claude Code connection timeout")
                    return
                end

                vim.defer_fn(check_connection, check_interval)
            end

            check_connection()
        end

        wait_for_claude_connection(function()
            restore_state(saved_state)

            if saved_state.mode == "v" or saved_state.mode == "V" then
                vim.defer_fn(function()
                    vim.cmd("ClaudeCodeSend")
                    vim.defer_fn(function()
                        vim.cmd("ClaudeCodeFocus")
                    end, 10)
                end, 10)
            else
                vim.cmd("ClaudeCodeAdd %")
                vim.cmd("ClaudeCodeFocus")
            end
        end)
    end
end

---@param bufid BufID
---@return boolean
function fn.is_claude_buf(bufid)
    if not vim.api.nvim_buf_is_loaded(bufid) then
        return false
    end

    return NVSTerminal.is_app("claude", bufid)
end

---@return boolean
function fn.is_claude_visible()
    return CCProvider.is_active()
end

---@return boolean
function fn.is_claude_active()
    local current_buf = vim.api.nvim_get_current_buf()
    return fn.is_claude_buf(current_buf)
end

---@return boolean
function fn.is_claude_connected()
    local tab_id = vim.api.nvim_get_current_tabpage()
    return CCProvider.is_connected(tab_id)
end

---@param path string
function NVClaudeCode.add_file(path)
    local ok, claudecode = pcall(require, "claudecode")
    if ok and claudecode.send_at_mention then
        claudecode.send_at_mention(path)
    end
end

return { NVClaudeCode }
