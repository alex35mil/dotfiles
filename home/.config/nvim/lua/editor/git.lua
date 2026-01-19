NVGit = {}

---
--- Worktrees
---

---@alias GitWorktreeInfo {path: string, branch: string}

---@param name string
---@return string
function NVGit.normalize_worktree_name(name)
    local result = name:lower()
    result = result:gsub("[%s_]+", "-")
    result = result:gsub("[^%w%-]", "")
    result = result:gsub("%-+", "-")
    result = result:gsub("^%-+", ""):gsub("%-+$", "")
    return result
end

---@param path? string
---@return GitWorktreeInfo?
function NVGit.get_worktree_info(path)
    path = path or vim.fn.getcwd(-1, 0)

    -- Check if this is actually a secondary worktree (not the main repo)
    -- In a worktree, .git is a file; in main repo, .git is a directory
    local git_path = path .. "/.git"
    if vim.fn.isdirectory(git_path) == 1 then
        return nil -- Main repo, not a worktree
    end

    local output = vim.fn.systemlist("git worktree list --porcelain")

    local current_path = nil
    local current_branch = nil
    for _, line in ipairs(output) do
        if line:match("^worktree ") then
            current_path = line:sub(10)
            current_branch = nil
        elseif line:match("^branch refs/heads/") then
            current_branch = line:sub(19)
            if current_path == path then
                return { path = current_path, branch = current_branch }
            end
        end
    end
    return nil
end

function NVGit.get_all_worktrees()
    local output = vim.fn.systemlist("git worktree list --porcelain")
    local worktrees = {}
    local current = {}

    for _, line in ipairs(output) do
        if line:match("^worktree ") then
            current = { path = line:sub(10) }
        elseif line:match("^branch refs/heads/") then
            current.branch = line:sub(19)
            table.insert(worktrees, current)
        elseif line == "bare" then
            current.bare = true
        end
    end

    return worktrees
end

function NVGit.find_worktree_for_branch(branch)
    local output = vim.fn.systemlist("git worktree list --porcelain")
    local current_path = nil
    for _, line in ipairs(output) do
        if line:match("^worktree ") then
            current_path = line:sub(10)
        elseif line:match("^branch refs/heads/" .. branch .. "$") then
            return current_path
        end
    end
    return nil
end

function NVGit.worktree_has_changes(path)
    local output = vim.fn.system("git -C " .. vim.fn.shellescape(path) .. " status --porcelain 2>&1")
    return vim.v.shell_error == 0 and output ~= ""
end

function NVGit.create_worktree(branch, path)
    -- Check if branch already has a worktree
    local existing = NVGit.find_worktree_for_branch(branch)
    if existing then
        return existing, "exists"
    end

    -- Check if branch exists
    vim.fn.system(string.format("git show-ref --verify --quiet refs/heads/%s", branch))
    local branch_exists = vim.v.shell_error == 0

    local cmd
    if branch_exists then
        cmd = string.format("git worktree add %s %s", vim.fn.shellescape(path), branch)
    else
        cmd = string.format("git worktree add -b %s %s", branch, vim.fn.shellescape(path))
    end

    vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        return nil, "failed"
    end

    return path, "created"
end

function NVGit.remove_worktree(path, force)
    local cmd = "git worktree remove " .. (force and "--force " or "") .. vim.fn.shellescape(path)
    vim.fn.system(cmd)
    return vim.v.shell_error == 0
end

function NVGit.delete_branch(branch)
    vim.fn.system("git branch -D " .. branch)
    return vim.v.shell_error == 0
end

function NVGit.get_worktree_config_path(worktree_path)
    -- Get the gitdir for this worktree which contains its config
    local gitdir = vim.fn.systemlist("git -C " .. vim.fn.shellescape(worktree_path) .. " rev-parse --git-dir")[1]
    if vim.v.shell_error ~= 0 or not gitdir then
        return nil
    end
    -- Make absolute if relative
    if not gitdir:match("^/") then
        gitdir = worktree_path .. "/" .. gitdir
    end
    return gitdir .. "/config.worktree"
end

function NVGit.get_worktree_label(path)
    local config_path = NVGit.get_worktree_config_path(path)
    if not config_path then
        return nil
    end
    local output =
        vim.fn.systemlist("git config --file " .. vim.fn.shellescape(config_path) .. " worktree.label 2>/dev/null")
    if vim.v.shell_error == 0 and output[1] and output[1] ~= "" then
        return output[1]
    end
    return nil
end

function NVGit.set_worktree_label(path, label)
    local config_path = NVGit.get_worktree_config_path(path)
    if not config_path then
        return false
    end
    vim.fn.system(
        "git config --file " .. vim.fn.shellescape(config_path) .. " worktree.label " .. vim.fn.shellescape(label)
    )
    return vim.v.shell_error == 0
end

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
