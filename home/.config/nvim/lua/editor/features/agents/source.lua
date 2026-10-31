-- The source checkout agents are cloned from: its state and updating it.

---@alias AgentSourceState
---| { kind: "ready", branch: string }
---| { kind: "dirty", status: string }
---| { kind: "off-default", branch: string?, default: string }
---| { kind: "unknown-default" }

local util = require("editor.features.agents.util")

local M = {}

---@param source string
---@return AgentSourceState
function M.state(source)
    local status = util.git_ok(source, { "status", "--porcelain" }, "git status failed in " .. source)
    if status ~= "" then
        return { kind = "dirty", status = status }
    end
    local default = util.git(source, { "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
    if default.code ~= 0 then
        return { kind = "unknown-default" }
    end
    local default_branch = vim.trim(default.stdout):gsub("^origin/", "")
    local head = util.git(source, { "symbolic-ref", "--quiet", "--short", "HEAD" })
    local branch = head.code == 0 and vim.trim(head.stdout) or nil
    if branch ~= default_branch then
        return { kind = "off-default", branch = branch, default = default_branch }
    end
    return { kind = "ready", branch = default_branch }
end

---@param source string
---@param state AgentSourceState
---@return string
function M.describe_state(source, state)
    if state.kind == "ready" then
        return source .. " is clean on " .. state.branch
    elseif state.kind == "dirty" then
        return source
            .. " has uncommitted changes:\n"
            .. table.concat(util.head(vim.split(state.status, "\n"), 15), "\n")
    elseif state.kind == "off-default" then
        return source .. " is on " .. (state.branch or "a detached HEAD") .. ", not " .. state.default
    elseif state.kind == "unknown-default" then
        return "can't tell the default branch of " .. source .. " (run `git remote set-head origin --auto`)"
    end
    error("unknown source state: " .. vim.inspect(state))
end

---@param source string
function M.update(source)
    local state = M.state(source)
    if state.kind ~= "ready" then
        log.warn("Source not updated, it may be behind: " .. M.describe_state(source, state))
        return
    end
    local upstream = "origin/" .. state.branch
    local fetch = util.git(source, { "fetch" })
    local merge = fetch.code == 0 and util.git(source, { "merge", "--ff-only", upstream })
    if fetch.code ~= 0 or not merge or merge.code ~= 0 then
        local failed = fetch.code ~= 0 and fetch or merge --[[@as vim.SystemCompleted]]
        log.warn("Source " .. source .. " is behind " .. upstream .. ":\n" .. vim.trim(failed.stderr))
        return
    end
    log.info("Fast-forwarded " .. source .. " to " .. upstream)
end

return M
