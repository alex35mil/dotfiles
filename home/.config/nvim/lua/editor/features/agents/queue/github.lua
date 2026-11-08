-- Todo and Backlog items of a GitHub Project: Todo first, each ordered by the
-- configured Priority, then by the Project's manual order.

local util = require("editor.features.agents.util")
local queue = require("editor.features.agents.queue")

local M = {}

local URL = "https://api.github.com/graphql"

---@param owner_type string
---@return string
local function items_query(owner_type)
    return ([[
query($owner: String!, $number: Int!, $status: String!, $priority: String!, $cursor: String) {
  owner: %s(login: $owner) {
    projectV2(number: $number) {
      items(first: 100, after: $cursor, orderBy: {field: POSITION, direction: ASC}) {
        pageInfo { hasNextPage endCursor }
        nodes {
          status: fieldValueByName(name: $status) {
            ... on ProjectV2ItemFieldSingleSelectValue { name }
          }
          priority: fieldValueByName(name: $priority) {
            ... on ProjectV2ItemFieldSingleSelectValue { name }
            ... on ProjectV2ItemIssueFieldValue {
              issueFieldValue { ... on IssueFieldSingleSelectValue { name } }
            }
          }
          content {
            __typename
            ... on PullRequest {
              number title url state
              repository { nameWithOwner }
            }
            ... on Issue {
              number title url state
              repository { nameWithOwner }
              labels(first: 50) { nodes { name } }
              parent { number title labels(first: 50) { nodes { name } } }
            }
          }
        }
      }
    }
  }
}]]):format(owner_type == "org" and "organization" or "user")
end

---@param tracker QueueTracker
---@return QueueItem[]
function M.load(tracker)
    local config = tracker.config
    local project = config.project
    local status = config.fields.status
    local priority = config.fields.priority
    local repository = config.repository.owner .. "/" .. config.repository.repo
    local epic_label = vim.tbl_get(config, "labels", "groups", "kind", "values", "epic", "name")

    local nodes = queue.paginate(function(cursor)
        local response = queue.post(tracker, URL, "Bearer {{VAR}}", items_query(project.ownerType), {
            owner = project.owner,
            number = project.number,
            status = status.field,
            priority = priority.field,
            cursor = cursor,
        })
        local items = vim.tbl_get(queue.data(URL, response), "owner", "projectV2", "items")
        if not items then
            util.refuse(("GitHub Project %s/%d not found"):format(project.owner, project.number))
        end
        return items
    end)

    local result = {} ---@type QueueItem[]
    local orders = {} ---@type table<QueueItem, QueueOrder>
    for position, node in ipairs(nodes) do
        local content = node.content
        local queue_status = queue.status_of(vim.tbl_get(node, "status", "name"), status.values)
        if
            queue_status
            and type(content) == "table"
            and content.number
            and content.state == "OPEN"
            and vim.tbl_get(content, "repository", "nameWithOwner") == repository
        then
            -- Issues and pull requests share one number sequence per repository.
            local marker = "#" .. content.number
            ---@type QueueItem
            local item = {
                id = "github:" .. repository .. marker,
                status = queue_status,
                mention = marker,
                marker = marker,
                title = content.title,
                url = content.url,
                kind = content.__typename == "PullRequest" and { kind = "pr" } or M.kind(content, epic_label),
            }
            table.insert(result, item)
            orders[item] = { rank = M.priority_rank(node.priority, priority.values), position = position }
        end
    end
    queue.sort_by_priority(result, function(item)
        return orders[item]
    end)
    return queue.group_by_status(result)
end

--- Rank of an item's Priority value in the configured order, whether the
--- field is the Project's own or an issue field shown on the Project; nil
--- when unset or not a configured value.
---@param value table? The item's `priority` field value.
---@param values string[] Configured Priority options, highest first.
---@return integer?
function M.priority_rank(value, values)
    if type(value) ~= "table" then
        return nil
    end
    local name = value.name or vim.tbl_get(value, "issueFieldValue", "name")
    for rank, option in ipairs(values) do
        if option == name then
            return rank
        end
    end
    return nil
end

---@param issue table
---@param label string?
---@return boolean
local function has_label(issue, label)
    for _, node in ipairs(vim.tbl_get(issue, "labels", "nodes") or {}) do
        if node.name == label then
            return true
        end
    end
    return false
end

--- A Task is a sub-issue of an Epic; an Epic or a Gig is top-level, told
--- apart by the configured Epic Kind label.
---@param issue table
---@param epic_label string?
---@return QueueKind
function M.kind(issue, epic_label)
    local parent = issue.parent
    if type(parent) == "table" and (not epic_label or has_label(parent, epic_label)) then
        local marker = "#" .. parent.number
        return { kind = "task", epic = { mention = marker, marker = marker, title = parent.title } }
    end
    if not epic_label then
        return { kind = "unclassified" }
    end
    if has_label(issue, epic_label) then
        return { kind = "epic" }
    end
    return { kind = "gig" }
end

return M
