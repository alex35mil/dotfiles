local fn = {}

NVClaudeCode = {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    event = "VeryLazy",
    keys = function()
        return {
            { "<D-S-c>", "<Esc><Cmd>ClaudeCode<CR>", mode = { "n", "i", "t", "v" }, desc = "Toggle Claude" },
            {
                "<C-S-c>",
                "<Cmd>ClaudeCode --continue<CR>",
                mode = { "n", "i", "t", "v" },
                desc = "Continue with last Claude session",
            },
            {
                "<M-S-c>",
                "<Cmd>ClaudeCode --resume<CR>",
                mode = { "n", "i", "t", "v" },
                desc = "Resume specific Claude session",
            },
            { "<D-p>", fn.post_and_focus, mode = { "n", "i", "v" }, desc = "Post to Claude and focus" },
            { "<C-CR>", fn.accept_diff, mode = { "n", "i", "v" }, desc = "Accept Claude diff" },
            { "<D-S-n>", fn.deny_diff, mode = { "n", "i", "v" }, desc = "Deny Claude diff (NOPE!)" },
        }
    end,
    opts = {
        terminal = {
            split_side = "right",
            split_width_percentage = 0.35,
        },
        diff_opts = {
            auto_close_on_accept = true,
            vertical_split = true,
            open_in_current_tab = false,
        },
    },
}

---@return boolean
function NVClaudeCode.ensure_hidden()
    if fn.is_claude_active() then
        vim.cmd("ClaudeCode")
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

function fn.accept_diff()
    if NVClaudeCode.is_diff_active() then
        vim.cmd("ClaudeCodeDiffAccept")
        vim.cmd("ClaudeCodeFocus")
    end
end

function fn.deny_diff()
    if NVClaudeCode.is_diff_active() then
        vim.cmd("ClaudeCodeDiffDeny")
        vim.cmd("ClaudeCodeFocus")
    end
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
                    if state.selection.mode == "v" then
                        vim.api.nvim_feedkeys("gv", "n", false)
                    elseif state.selection.mode == "V" then
                        vim.api.nvim_feedkeys("gV", "n", false)
                    end
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
            local start_time = vim.loop.hrtime()
            local timeout_ns = 10 * 1000 * 1000 * 1000 -- 5 seconds in nanoseconds
            local check_interval = 100 -- milliseconds

            local function check_connection()
                local elapsed = vim.loop.hrtime() - start_time

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
    local current_tab = vim.api.nvim_get_current_tabpage()
    local windows = vim.api.nvim_tabpage_list_wins(current_tab)

    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        if fn.is_claude_buf(buf) then
            return true
        end
    end

    return false
end

---@return boolean
function fn.is_claude_active()
    local current_buf = vim.api.nvim_get_current_buf()
    return fn.is_claude_buf(current_buf)
end

---@return boolean
function fn.is_claude_connected()
    return require("claudecode").is_claude_connected()
end

return { NVClaudeCode }
