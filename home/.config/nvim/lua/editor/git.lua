NVGit = {}

---
--- Repo
---

function NVGit.get_repo_info()
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
        return nil
    end

    return {
        root = git_root,
        name = vim.fn.fnamemodify(git_root, ":t"),
        parent = vim.fn.fnamemodify(git_root, ":h"),
    }
end

---
--- Diffs
---

function NVGit.has_staged_changes()
    vim.fn.system("git diff --cached --quiet")
    return vim.v.shell_error ~= 0
end

function NVGit.has_unstaged_changes()
    vim.fn.system("git diff --quiet")
    return vim.v.shell_error ~= 0
end

function NVGit.get_staged_files_count()
    local output = vim.fn.systemlist("git diff --cached --name-only 2>/dev/null")
    if vim.v.shell_error ~= 0 then
        return 0
    end
    return #output
end

---
--- Commit & Push
---

---@param subject string
---@param body? string
---@param extra_args? string[]
---@return string output
function NVGit.commit(subject, body, extra_args)
    local args = { "git", "commit", "-m", subject }
    if body and body ~= "" then
        table.insert(args, "-m")
        table.insert(args, body)
    end
    if extra_args then
        for _, arg in ipairs(extra_args) do
            table.insert(args, arg)
        end
    end
    return vim.fn.system(args)
end

---@param count number
---@return string[]
function NVGit.get_recent_commits(count)
    local output = vim.fn.systemlist("git log --max-count=" .. count .. " --format='%s · %cr' 2>/dev/null")
    if vim.v.shell_error ~= 0 then
        return {}
    end
    return vim.tbl_map(function(line)
        local dt = line
            -- Handle combined dates like "1 year, 6 months ago"
            :gsub(
                "(%d+) years?, (%d+) months? ago",
                "%1y %2mo"
            )
            :gsub("(%d+) months?, (%d+) weeks? ago", "%1mo %2w")
            -- Simple dates
            :gsub("(%d+) seconds? ago", "%1s")
            :gsub("(%d+) minutes? ago", "%1m")
            :gsub("(%d+) hours? ago", "%1h")
            :gsub("(%d+) days? ago", "%1d")
            :gsub("(%d+) weeks? ago", "%1w")
            :gsub("(%d+) months? ago", "%1mo")
            :gsub("(%d+) years? ago", "%1y")
        return dt .. " ago"
    end, output)
end

---@return string subject, string body
function NVGit.get_last_commit_message()
    local subject = vim.fn.system("git log -1 --format=%s 2>/dev/null"):gsub("\n", "")
    local body = vim.fn.system("git log -1 --format=%b 2>/dev/null"):gsub("\n$", "")
    return subject, body
end

function NVGit.push()
    vim.fn.system("git push")
    return vim.v.shell_error == 0
end

function NVGit.push_force_with_lease()
    vim.fn.system("git push --force-with-lease")
    return vim.v.shell_error == 0
end

---Amend last commit without changing the message
---@return string output
function NVGit.amend_no_edit()
    return vim.fn.system("git commit --amend --no-edit")
end

---Amend last commit with a new message
---@param subject string
---@param body? string
---@return string output
function NVGit.amend_message(subject, body)
    local args = { "git", "commit", "--amend", "-m", subject }
    if body and body ~= "" then
        table.insert(args, "-m")
        table.insert(args, body)
    end
    return vim.fn.system(args)
end
