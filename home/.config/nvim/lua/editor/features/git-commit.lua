NVGitCommit = {}

-- If changing those, don't forget to update footer labels
local keymaps = {
    commit_from_subject = "<CR>",
    commit_from_body = "<C-CR>",
    commit_and_push = "<D-CR>",
    cancel = { NVKeymaps.close, "<Esc>" },
    next_field = { "<Tab>", "<S-CR>" },
    prev_field = "<S-Tab>",
}

-- Should have its own highlights, but I'm lazy
local highlights = {
    backdrop = "Normal",
    normal = "Normal",
    border = "Comment",
    title = "GitCommitTitle",
    commit_message = "Comment",
    commit_date = "GitCommitDate",
    footer_key = "Comment",
    footer_action = "NonText",
    footer_separator = "FloatBorder",
    char_count = "FloatBorder",
    error = "DiagnosticError",
}

local function setup_highlights()
    local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
    vim.api.nvim_set_hl(0, highlights.title, vim.tbl_extend("force", comment_hl, { bold = true }))
    vim.api.nvim_set_hl(0, highlights.commit_date, vim.tbl_extend("force", comment_hl, { italic = true }))
end

local function get_winhighlight()
    return table.concat({
        "Normal:" .. highlights.normal,
        "FloatBorder:" .. highlights.border,
        "FloatTitle:" .. highlights.title,
    }, ",")
end

local MAX_SUBJECT_LEN = 72
local PREVIEW_LINES = 5

---@class GitCommitWinState
---@field win WinID?
---@field buf BufID?

local state = {
    subject = { win = nil, buf = nil }, ---@type GitCommitWinState
    body = { win = nil, buf = nil }, ---@type GitCommitWinState
    preview = { win = nil, buf = nil }, ---@type GitCommitWinState
    backdrop = { win = nil, buf = nil }, ---@type GitCommitWinState
    aborted_msg = {}, ---@type table<string, { subject: string, body: string }>
    original_msg = { subject = "", body = "" },
    mode = "commit", ---@type "commit" | "rename" | "amend"
}

local alert_title = "Git Commit"

local alert = {
    info = function(msg)
        vim.notify(msg, vim.log.levels.INFO, { title = alert_title })
    end,
    warn = function(msg)
        vim.notify(msg, vim.log.levels.WARN, { title = alert_title })
    end,
    error = function(msg)
        vim.notify(msg, vim.log.levels.ERROR, { title = alert_title })
    end,
}

---
--- Helpers
---

local function get_subject_text()
    if not state.subject.buf or not vim.api.nvim_buf_is_valid(state.subject.buf) then
        return ""
    end
    return vim.trim(vim.api.nvim_buf_get_lines(state.subject.buf, 0, 1, false)[1] or "")
end

local function get_body_text()
    if not state.body.buf or not vim.api.nvim_buf_is_valid(state.body.buf) then
        return ""
    end
    local lines = vim.api.nvim_buf_get_lines(state.body.buf, 0, -1, false)
    return vim.trim(table.concat(lines, "\n"))
end

local function save_message()
    local cwd = vim.uv.cwd() or ""
    state.aborted_msg[cwd] = {
        subject = get_subject_text(),
        body = get_body_text(),
    }
end

local function get_saved_message()
    local cwd = vim.uv.cwd() or ""
    return state.aborted_msg[cwd]
end

local function clear_saved_message()
    local cwd = vim.uv.cwd() or ""
    state.aborted_msg[cwd] = nil
end

---@param s GitCommitWinState
local function close_win_state(s)
    if s.win and vim.api.nvim_win_is_valid(s.win) then
        vim.api.nvim_win_close(s.win, true)
    end
    if s.buf and vim.api.nvim_buf_is_valid(s.buf) then
        vim.api.nvim_buf_delete(s.buf, { force = true })
    end
    s.win = nil
    s.buf = nil
end

local function close_form_windows()
    close_win_state(state.preview)
    close_win_state(state.body)
    close_win_state(state.subject)
    close_win_state(state.backdrop)
end

local function message_changed()
    local subject = get_subject_text()
    local body = get_body_text()
    return subject ~= state.original_msg.subject or body ~= state.original_msg.body
end

---
--- Commit Form
---

local function do_commit(push)
    local subject = get_subject_text()
    local body = get_body_text()

    -- Validate
    if #subject == 0 then
        alert.warn("Subject is empty")
        return
    end
    if #subject > MAX_SUBJECT_LEN then
        alert.warn("Subject is too long (" .. #subject .. "/" .. MAX_SUBJECT_LEN .. ")")
        return
    end

    local result
    local action

    if state.mode == "commit" then
        if not NVGit.has_staged_changes() then
            alert.warn("Nothing staged to commit")
            return
        end
        result = NVGit.commit(subject, body)
        action = "Committed"
    elseif state.mode == "rename" then
        -- Rename: only change message, no staging
        if not message_changed() then
            close_form_windows()
            vim.cmd.stopinsert()
            alert.info("No changes made")
            return
        end
        result = NVGit.amend_message(subject, body)
        action = "Renamed"
    elseif state.mode == "amend" then
        -- Amend: add staged changes, optionally change message
        if message_changed() then
            result = NVGit.amend_message(subject, body)
            action = "Amended"
        else
            result = NVGit.amend_no_edit()
            action = "Amended"
        end
    end

    if vim.v.shell_error ~= 0 then
        alert.error((action or "Action") .. " failed: " .. result)
        return
    end

    -- Clear saved message on success (only for new commits)
    if state.mode == "commit" then
        clear_saved_message()
    end

    -- Push if requested (rename/amend rewrite history, use force-with-lease)
    if push then
        if state.mode == "commit" then
            NVGit.push()
        else
            NVGit.push_force_with_lease()
        end
    end

    close_form_windows()
    vim.cmd.stopinsert()

    local push_msg = push and " and pushed" or ""
    alert.info(action .. push_msg .. ": " .. subject)
end

local function abort_form()
    -- Guard against double-close (keymap + WinLeave autocmd)
    if not state.subject.win then
        return
    end
    if state.mode == "commit" then
        save_message()
    end
    close_form_windows()
    vim.cmd.stopinsert()
end

local function setup_form_keymaps(bufnr)
    local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, nowait = true, silent = true })
    end

    -- Commit and push
    map({ "n", "i" }, keymaps.commit_and_push, function()
        do_commit(true)
    end)

    -- Cancel
    for _, key in ipairs(keymaps.cancel) do
        map("n", key, abort_form)
    end

    -- Navigate between subject and body
    local function go_next_field()
        if vim.api.nvim_get_current_win() == state.subject.win then
            vim.api.nvim_set_current_win(state.body.win)
        else
            vim.api.nvim_set_current_win(state.subject.win)
        end
        vim.schedule(function()
            vim.cmd.startinsert({ bang = true })
        end)
    end
    local function go_prev_field()
        if vim.api.nvim_get_current_win() == state.body.win then
            vim.api.nvim_set_current_win(state.subject.win)
        else
            vim.api.nvim_set_current_win(state.body.win)
        end
        vim.schedule(function()
            vim.cmd.startinsert({ bang = true })
        end)
    end
    for _, key in ipairs(keymaps.next_field) do
        map({ "n", "i" }, key, go_next_field)
    end
    map({ "n", "i" }, keymaps.prev_field, go_prev_field)
end

local function setup_char_counter(winid, bufnr)
    local function update_char_count()
        if not vim.api.nvim_win_is_valid(winid) then
            return
        end

        local text = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
        local count = #text
        local count_hl = count <= MAX_SUBJECT_LEN and highlights.char_count or highlights.error

        local conf = vim.api.nvim_win_get_config(winid)
        local action_labels = { commit = "commit", rename = "rename", amend = "amend" }
        conf.footer = {
            { " ↵  ", highlights.footer_key },
            { action_labels[state.mode], highlights.footer_action },
            { " · ", highlights.footer_separator },
            { "⌘ ↵  ", highlights.footer_key },
            { "+push", highlights.footer_action },
            { " · ", highlights.footer_separator },
            { "⌘ W ", highlights.footer_key },
            { "cancel", highlights.footer_action },
            { " ─── ", highlights.footer_separator },
            { tostring(count), count_hl },
            { "/" .. MAX_SUBJECT_LEN .. " ", highlights.footer_separator },
        }
        conf.footer_pos = "right"
        vim.api.nvim_win_set_config(winid, conf)
    end

    update_char_count()
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = bufnr,
        callback = update_char_count,
    })
end

local function setup_form_unmount(bufnr)
    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = bufnr,
        callback = function()
            vim.schedule(function()
                local cur_win = vim.api.nvim_get_current_win()
                local form_wins = { state.backdrop.win, state.subject.win, state.body.win, state.preview.win }
                for _, win in ipairs(form_wins) do
                    if cur_win == win then
                        return
                    end
                end
                abort_form()
            end)
        end,
    })
end

local function create_backdrop_window()
    local bufnr = vim.api.nvim_create_buf(false, true)

    local winid = vim.api.nvim_open_win(bufnr, false, {
        relative = "editor",
        width = vim.o.columns,
        height = vim.o.lines,
        row = 0,
        col = 0,
        style = "minimal",
        border = "none",
        focusable = false,
        zindex = 40,
    })

    state.backdrop.win = winid
    state.backdrop.buf = bufnr

    vim.wo[winid].winhighlight = "Normal:" .. highlights.backdrop

    return winid, bufnr
end

local function create_subject_window(title, initial_text)
    local width = MAX_SUBJECT_LEN + 2
    local height = 1

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { initial_text or "" })

    local total_height = height + 4 + PREVIEW_LINES + 4
    local row = math.floor((vim.o.lines - total_height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local winid = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
        title = " " .. title .. " ",
        title_pos = "left",
        style = "minimal",
    })

    state.subject.win = winid
    state.subject.buf = bufnr

    vim.bo[bufnr].filetype = "gitcommit"
    vim.wo[winid].wrap = false
    vim.wo[winid].spell = true
    vim.wo[winid].cursorline = false
    vim.wo[winid].statuscolumn = " "
    vim.wo[winid].winhighlight = get_winhighlight()

    setup_form_keymaps(bufnr)
    setup_char_counter(winid, bufnr)
    setup_form_unmount(bufnr)

    -- <CR> in subject commits
    vim.keymap.set({ "n", "i" }, keymaps.commit_from_subject, function()
        do_commit(false)
    end, { buffer = bufnr, nowait = true, silent = true })

    -- Highlight over-length text
    vim.api.nvim_win_call(winid, function()
        vim.fn.matchadd(highlights.error, [[\%>]] .. MAX_SUBJECT_LEN .. [[v.]])
    end)

    return winid, bufnr
end

local function create_body_window(initial_text)
    local width = MAX_SUBJECT_LEN + 2
    local height = 4

    local bufnr = vim.api.nvim_create_buf(false, true)
    local lines = initial_text and vim.split(initial_text, "\n") or { "" }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    local staged_count = NVGit.get_staged_files_count()
    local footer
    if staged_count > 0 then
        footer = {
            { " " .. staged_count .. " file" .. (staged_count > 1 and "s" or "") .. " staged ", highlights.char_count },
        }
    elseif state.mode == "commit" then
        footer = {
            { " nothing staged ", highlights.error },
        }
    end

    local winid = vim.api.nvim_open_win(bufnr, false, {
        relative = "win",
        win = state.subject.win,
        width = width,
        height = height,
        row = 2,
        col = -1,
        border = "rounded",
        title = " Description (optional) ",
        title_pos = "left",
        footer = footer,
        footer_pos = "right",
        style = "minimal",
    })

    state.body.win = winid
    state.body.buf = bufnr

    vim.bo[bufnr].filetype = "gitcommit"
    vim.wo[winid].wrap = true
    vim.wo[winid].spell = true
    vim.wo[winid].cursorline = false
    vim.wo[winid].statuscolumn = " "
    vim.wo[winid].winhighlight = get_winhighlight()

    setup_form_keymaps(bufnr)

    -- <C-CR> in body commits
    vim.keymap.set({ "n", "i" }, keymaps.commit_from_body, function()
        do_commit(false)
    end, { buffer = bufnr, nowait = true, silent = true })

    return winid, bufnr
end

local function create_preview_window()
    local width = MAX_SUBJECT_LEN + 2

    local commits = NVGit.get_recent_commits(PREVIEW_LINES)
    local height = math.min(#commits, PREVIEW_LINES)

    if height == 0 then
        return nil, nil
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, commits)

    local winid = vim.api.nvim_open_win(bufnr, false, {
        relative = "win",
        win = state.body.win,
        width = width,
        height = height,
        row = 5,
        col = -1,
        border = "rounded",
        title = " Recent commits ",
        title_pos = "left",
        style = "minimal",
        focusable = false,
    })

    -- Style commits: message in Comment, date in italic
    local ns = vim.api.nvim_create_namespace("git_commit_preview")
    local separator = " · " -- 4 bytes: space + middot (2 bytes) + space
    for i, line in ipairs(commits) do
        local date_start = line:find(" · %d+%a* ago$") or line:find(" · %d+%a* %d+%a* ago$")
        if date_start then
            -- Message (before separator)
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                end_col = date_start - 1,
                hl_group = highlights.commit_message,
            })
            -- Separator " · " (non-italic)
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, date_start - 1, {
                end_col = date_start - 1 + #separator,
                hl_group = highlights.commit_message,
            })
            -- Date (italic)
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, date_start - 1 + #separator, {
                end_col = #line,
                hl_group = highlights.commit_date,
            })
        else
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                end_col = #line,
                hl_group = highlights.commit_message,
            })
        end
    end

    state.preview.win = winid
    state.preview.buf = bufnr

    vim.bo[bufnr].modifiable = false
    vim.wo[winid].cursorline = false
    vim.wo[winid].statuscolumn = " "
    vim.wo[winid].winhighlight = get_winhighlight()

    return winid, bufnr
end

local function open_form(opts)
    opts = opts or {}
    state.mode = opts.mode or "commit"
    setup_highlights()

    -- Get initial text
    local subject_text = ""
    local body_text = ""

    if state.mode == "rename" or state.mode == "amend" then
        subject_text, body_text = NVGit.get_last_commit_message()
        -- Store original for change detection
        state.original_msg = { subject = subject_text, body = body_text }
    else
        -- New commit: restore saved message if any
        state.original_msg = { subject = "", body = "" }
        local saved = get_saved_message()
        if saved then
            subject_text = saved.subject or ""
            body_text = saved.body or ""
        end
    end

    -- Create windows
    local titles = {
        commit = "󰊢 Commit",
        rename = "󰊢 Rename",
        amend = "󰊢 Amend",
    }
    create_backdrop_window()
    create_subject_window(titles[state.mode], subject_text)
    create_body_window(body_text)
    create_preview_window()

    -- Focus subject and start insert
    vim.api.nvim_set_current_win(state.subject.win)
    vim.cmd.startinsert({ bang = true })
end

---
--- Public API
---

function NVGitCommit.new()
    if NVGit.get_repo_info() == nil then
        alert.error("Not in a git repository")
        return
    end
    open_form({ mode = "commit" })
end

function NVGitCommit.rename()
    if NVGit.get_repo_info() == nil then
        alert.error("Not in a git repository")
        return
    end
    open_form({ mode = "rename" })
end

function NVGitCommit.amend()
    if NVGit.get_repo_info() == nil then
        alert.error("Not in a git repository")
        return
    end
    if not NVGit.has_staged_changes() then
        alert.info("Nothing staged to amend")
        return
    end
    open_form({ mode = "amend" })
end

function NVGitCommit.ensure_hidden()
    if state.subject.win and vim.api.nvim_win_is_valid(state.subject.win) then
        abort_form()
        return true
    end
    return false
end

function NVGitCommit.keymaps()
    K.map({ "<D-g>c", "Git: Commit", NVGitCommit.new, mode = { "n", "i", "v" } })
    K.map({ "<D-g>a", "Git: Amend", NVGitCommit.amend, mode = { "n", "i", "v" } })
    K.map({ "<D-g>r", "Git: Rename last commit", NVGitCommit.rename, mode = { "n", "i", "v" } })
end
