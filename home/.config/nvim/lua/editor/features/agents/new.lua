-- The new-agent picker: adopt a queued Todo or Backlog item, or create a
-- plain agent named by what's typed, always offered as the last row. Queued
-- items load when it opens, Todo above Backlog.

---@alias NewAgentEntry
---| { kind: "queued", item: QueueItem }
---| { kind: "named" } Named by the typed text, which its `text` mirrors so it always matches.

---@alias NewAgentQueueState
---| { kind: "loading" }
---| { kind: "loaded", todo: integer, backlog: integer }
---| { kind: "unavailable", message: string }

local util = require("editor.features.agents.util")
local lookup = require("editor.features.agents.lookup")
local create = require("editor.features.agents.create")
local queue = require("editor.features.agents.queue")

local M = {}

local ISSUE_ICON = ""
local PR_ICON = ""

-- Picker groups, top to bottom; `sort` keeps them apart whatever the score.
local NAMED_GROUP = 2

---@param status QueueStatus
---@return integer
local function status_group(status)
    if status == "todo" then
        return 0
    elseif status == "backlog" then
        return 1
    end
    error("unknown queue status: " .. vim.inspect(status))
end

---@param status QueueStatus
---@return string
local function status_text(status)
    if status == "todo" then
        return "Todo"
    elseif status == "backlog" then
        return "Backlog"
    end
    error("unknown queue status: " .. vim.inspect(status))
end

---@param state NewAgentQueueState
---@return string
local function title(state)
    if state.kind == "loading" then
        return "New agent · loading queue…"
    elseif state.kind == "loaded" then
        return ("New agent · %d Todo%s · %d Backlog"):format(state.todo, state.todo == 1 and "" or "s", state.backlog)
    elseif state.kind == "unavailable" then
        return "New agent · queue unavailable"
    end
    error("unknown queue state: " .. vim.inspect(state))
end

---@param item QueueItem
---@return string
local function kind_text(item)
    local kind = item.kind
    if kind.kind == "epic" then
        return "Epic"
    elseif kind.kind == "task" then
        return "Task of Epic " .. (kind.epic.marker or kind.epic.title)
    elseif kind.kind == "gig" then
        return "Gig"
    elseif kind.kind == "pr" then
        return "Pull request"
    elseif kind.kind == "unclassified" then
        return "Unclassified (no Epic Kind label configured)"
    end
    error("unknown queue kind: " .. vim.inspect(kind))
end

---@param item QueueItem
---@return string
function M.icon(item)
    local kind = item.kind
    if kind.kind == "pr" then
        return PR_ICON
    elseif kind.kind == "epic" or kind.kind == "task" or kind.kind == "gig" or kind.kind == "unclassified" then
        return ISSUE_ICON
    end
    error("unknown queue kind: " .. vim.inspect(kind))
end

function M.pick()
    local source = lookup.current_source()
    if not source then
        log.error("Not in a git repository")
        return
    end

    local started = {} ---@type table<string, true>
    for _, agent in ipairs(lookup.list(source)) do
        if agent.issue then
            started[agent.issue] = true
        end
    end

    local named = { text = "", group = NAMED_GROUP, entry = { kind = "named" } }
    local queued_items = {} ---@type snacks.picker.finder.Item[]
    ---@type NewAgentQueueState
    local state = { kind = "loading" }

    local picker = Snacks.picker({
        title = title(state),
        finder = function()
            local items = vim.list_extend({}, queued_items)
            table.insert(items, named)
            return items
        end,
        filter = {
            -- Runs before matching on every input change.
            transform = function(_, filter)
                named.text = filter.pattern
            end,
        },
        sort = { fields = { "group", "score:desc", "idx" } },
        format = function(item)
            local entry = item.entry ---@type NewAgentEntry
            if entry.kind == "named" then
                if item.text == "" then
                    return { { "+ ", "SnacksPickerIcon" }, { "New agent: type a name", "Comment" } }
                end
                return { { "+ ", "SnacksPickerIcon" }, { "New agent: ", "Comment" }, { item.text } }
            end
            local queued = entry.item
            local parts = { { M.icon(queued) .. " ", "SnacksPickerIcon" } }
            if queued.marker then
                table.insert(parts, { queued.marker .. " ", "Comment" })
            end
            table.insert(parts, { queued.title })
            local kind = queued.kind
            if kind.kind == "task" then
                table.insert(parts, { " · Epic " .. (kind.epic.marker or kind.epic.title), "Comment" })
            elseif kind.kind == "epic" then
                table.insert(parts, { " · Epic", "Comment" })
            elseif kind.kind == "gig" or kind.kind == "pr" or kind.kind == "unclassified" then
                -- The plain case: nothing to add.
            end
            if queued.status == "backlog" then
                table.insert(parts, { " · Backlog", "Comment" })
            elseif queued.status == "todo" then
                -- The default: nothing to add.
            end
            return parts
        end,
        preview = function(ctx)
            local entry = ctx.item.entry ---@type NewAgentEntry
            if entry.kind == "named" then
                local name = create.normalize_name(ctx.item.text)
                ctx.preview:set_lines({
                    "Plain agent, no tracker item",
                    "",
                    "Agent: " .. (name ~= "" and (vim.fs.basename(source) .. "--" .. name) or "(type a name)"),
                })
                return
            end
            local queued = entry.item
            ctx.preview:set_lines({
                queued.title,
                "",
                "Kind: " .. kind_text(queued),
                "Status: " .. status_text(queued.status),
                "URL: " .. queued.url,
                "Agent: " .. vim.fs.basename(source) .. "--" .. queue.agent_name(queued),
                "Prompt: " .. (queue.command(queued) or "(empty)"),
            })
        end,
        confirm = function(p, item)
            if not item then
                return
            end
            local entry = item.entry ---@type NewAgentEntry
            if entry.kind == "queued" then
                p:close()
                create.create({ kind = "queued", item = entry.item })
            elseif entry.kind == "named" then
                local name = vim.trim(p.input:get() or "")
                if name ~= "" then
                    p:close()
                    create.create({ kind = "named", name = name })
                end
            end
        end,
    })

    ---@param next_state NewAgentQueueState
    local function update(next_state)
        state = next_state
        if picker.closed then
            return
        end
        picker.title = title(state)
        picker:update_titles()
        picker:find({ refresh = true })
    end

    util.async(function()
        local result = util.catch(function()
            return queue.load(source)
        end)
        if result.kind == "ok" then
            local counts = { todo = 0, backlog = 0 } ---@type table<QueueStatus, integer>
            for _, queued in
                ipairs(result.value --[[@as QueueItem[] ]])
            do
                if not started[queued.id] then
                    local text = table.concat(
                        { queued.marker or "", queued.title, kind_text(queued), status_text(queued.status) },
                        " "
                    )
                    table.insert(queued_items, {
                        text = text,
                        group = status_group(queued.status),
                        entry = { kind = "queued", item = queued },
                    })
                    counts[queued.status] = counts[queued.status] + 1
                end
            end
            update({ kind = "loaded", todo = counts.todo, backlog = counts.backlog })
        elseif result.kind == "refused" then
            log.warn(result.message)
            update({ kind = "unavailable", message = result.message })
        elseif result.kind == "crashed" then
            log.error(result.message)
            update({ kind = "unavailable", message = result.message })
        end
    end)
end

return M
