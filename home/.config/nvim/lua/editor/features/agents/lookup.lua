-- Finding agents and the source they belong to.

---@class Agent
---@field path string Agent checkout (its git root).
---@field source string Checkout the agent was cloned from.
---@field label string Name the agent was created with.
---@field issue string? Identity of the tracker item the agent was created for.

local util = require("editor.features.agents.util")

local M = {}

--- The agent containing `path`, or nil when it isn't inside one.
---@param path string
---@return Agent?
function M.get(path)
    local root = util.git_root(path)
    if not root then
        return nil
    end
    local source = util.git(root, { "config", "--local", "--get", "agent.source" })
    if source.code ~= 0 then
        return nil
    end
    local label = util.git(root, { "config", "--local", "--get", "agent.label" })
    local issue = util.git(root, { "config", "--local", "--get", "agent.issue" })
    return {
        path = root,
        source = vim.trim(source.stdout),
        label = label.code == 0 and vim.trim(label.stdout) or vim.fs.basename(root),
        issue = issue.code == 0 and vim.trim(issue.stdout) or nil,
    }
end

---@param source string
---@return Agent[]
function M.list(source)
    local parent = vim.fs.dirname(source)
    local prefix = vim.fs.basename(source) .. "--"
    local agents = {}
    for name, type in vim.fs.dir(parent) do
        if type == "directory" and vim.startswith(name, prefix) then
            local agent = M.get(vim.fs.joinpath(parent, name))
            if agent and agent.path == vim.fs.joinpath(parent, name) and agent.source == source then
                table.insert(agents, agent)
            end
        end
    end
    table.sort(agents, function(a, b)
        return a.path < b.path
    end)
    return agents
end

--- The checkout agents are created from: the current tab's repository, or
--- the source of the agent the tab is in.
---@return string? source, string? root
function M.current_source()
    local root = util.git_root(vim.fn.getcwd())
    if not root then
        return nil, nil
    end
    local agent = M.get(root)
    return agent and agent.source or root, root
end

return M
