-- Creating an agent next to its source, as `<parent>/<repo>--<name>`.

---@alias AgentRequest
---| { kind: "named", name: string } A plain agent with a typed name.
---| { kind: "queued", item: QueueItem } An agent that adopts queued tracker work.

local util = require("editor.features.agents.util")
local lookup = require("editor.features.agents.lookup")
local source_mod = require("editor.features.agents.source")
local clone = require("editor.features.agents.clone")
local tabs = require("editor.features.agents.tabs")
local queue = require("editor.features.agents.queue")

local M = {}

---@class AgentPlan
---@field name string Directory suffix, before normalizing.
---@field label string
---@field issue string?
---@field draft string? Kickoff command pre-filled in the Pi prompt.

---@param request AgentRequest
---@return AgentPlan
function M.plan(request)
    if request.kind == "named" then
        return { name = request.name, label = request.name }
    elseif request.kind == "queued" then
        local item = request.item
        return {
            name = queue.agent_name(item),
            label = queue.agent_label(item),
            issue = item.id,
            draft = queue.command(item),
        }
    end
    error("unknown agent request: " .. vim.inspect(request))
end

---@param request AgentRequest
function M.create(request)
    local source, root = lookup.current_source()
    local relative_file = root and tabs.relative_file(root)
    local plan = M.plan(request)
    local name = plan.name

    util.async(function()
        if not source then
            util.refuse("Not in a git repository")
        end
        ---@cast source string

        local normalized = M.normalize_name(name)
        if normalized == "" then
            util.refuse("Invalid agent name: " .. name)
        end

        local path = vim.fs.joinpath(vim.fs.dirname(source), vim.fs.basename(source) .. "--" .. normalized)
        if vim.uv.fs_lstat(path) then
            util.refuse("Already exists: " .. path)
        end

        local state = source_mod.state(source)
        if state.kind ~= "ready" then
            util.refuse("Can't create an agent: " .. source_mod.describe_state(source, state))
        end

        log.info("Updating " .. source .. "…")
        util.git_ok(source, { "fetch" }, "git fetch failed in " .. source)
        util.git_ok(source, { "merge", "--ff-only", "origin/" .. state.branch }, "Can't fast-forward " .. source)

        -- Created here, outside the cleanup below, so a failure never removes
        -- a directory this run didn't create.
        clone.mkdir_like(source, path)
        local ok, err = pcall(function()
            clone.clone(source, path)
            clone.setup({ source = source, path = path, label = plan.label, issue = plan.issue })
        end)
        if not ok then
            util.exec({ "rm", "-rf", "--", path })
            error(err, 0)
        end

        tabs.open({ path = path, label = plan.label }, relative_file, plan.draft)
    end)
end

---@param name string
---@return string
function M.normalize_name(name)
    local result = name:lower()
    result = result:gsub("[%s_]+", "-")
    result = result:gsub("[^%w%-]", "")
    result = result:gsub("%-+", "-")
    result = result:gsub("^%-+", ""):gsub("%-+$", "")
    return result
end

return M
