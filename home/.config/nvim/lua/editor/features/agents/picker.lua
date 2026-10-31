-- The agent picker: the source and its agents.

---@alias AgentPickerEntry
---| { kind: "source", path: string }
---| { kind: "agent", agent: Agent }

local lookup = require("editor.features.agents.lookup")
local tabs = require("editor.features.agents.tabs")
local create = require("editor.features.agents.create")

local M = {}

function M.pick()
    local source, root = lookup.current_source()
    if not source then
        log.error("Not in a git repository")
        return
    end
    ---@cast root string
    local relative_file = tabs.relative_file(root)

    local current_cwd = vim.fn.getcwd(-1, 0)
    ---@type AgentPickerEntry
    local source_entry = { kind = "source", path = source }
    -- `pinned` keeps the source first, above any score.
    local items = { { text = vim.fs.basename(source), entry = source_entry, pinned = true } }
    local current_idx = 1
    for _, agent in ipairs(lookup.list(source)) do
        ---@type AgentPickerEntry
        local entry = { kind = "agent", agent = agent }
        table.insert(items, { text = agent.label, entry = entry, pinned = false })
        if agent.path == current_cwd then
            current_idx = #items
        end
    end

    Snacks.picker({
        title = "Agents",
        items = items,
        matcher = { fuzzy = false, regex = true },
        sort = { fields = { "pinned", "score:desc", "#text", "idx" } },
        on_show = function(picker)
            if current_idx > 1 then
                picker.list:move(current_idx, true)
            end
        end,
        format = function(item)
            local entry = item.entry ---@type AgentPickerEntry
            local icon, path
            if entry.kind == "source" then
                icon, path = tabs.SOURCE_ICON, entry.path
            elseif entry.kind == "agent" then
                icon, path = tabs.ICON, entry.agent.path
            end
            local tab = tabs.find(path)
            return { { icon .. " ", tab and "SnacksPickerIcon" or "Comment" }, { item.text } }
        end,
        confirm = function(picker, item)
            if item then
                picker:close()
                local entry = item.entry ---@type AgentPickerEntry
                if entry.kind == "source" then
                    tabs.switch_to_source(entry.path, relative_file)
                elseif entry.kind == "agent" then
                    tabs.switch_to(entry.agent, relative_file)
                end
            else
                local filter = picker.input:get()
                if filter and filter ~= "" then
                    picker:close()
                    create.create(filter)
                end
            end
        end,
        preview = function(ctx)
            local entry = ctx.item.entry ---@type AgentPickerEntry
            if entry.kind == "source" then
                ctx.preview:set_lines({ "Path: " .. entry.path, "Source repository" })
            elseif entry.kind == "agent" then
                ctx.preview:set_lines({ "Path: " .. entry.agent.path, "Source: " .. entry.agent.source })
            end
        end,
    })
end

return M
