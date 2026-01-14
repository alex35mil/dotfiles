NVGit = {}

function NVGit.normalize_worktree_name(name)
    local result = name:lower()
    result = result:gsub("[%s_]+", "-")
    result = result:gsub("[^%w%-]", "")
    result = result:gsub("%-+", "-")
    result = result:gsub("^%-+", ""):gsub("%-+$", "")
    return result
end

function NVGit.get_worktree_info(path)
    path = path or vim.fn.getcwd(-1, 0)
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
    local output = vim.fn.systemlist("git config --file " .. vim.fn.shellescape(config_path) .. " worktree.label 2>/dev/null")
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
    vim.fn.system("git config --file " .. vim.fn.shellescape(config_path) .. " worktree.label " .. vim.fn.shellescape(label))
    return vim.v.shell_error == 0
end

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
