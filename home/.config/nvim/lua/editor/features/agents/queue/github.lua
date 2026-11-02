-- Todo items of a GitHub Project, in the Project's order.

local util = require("editor.features.agents.util")
local queue = require("editor.features.agents.queue")

local M = {}

local URL = "https://api.github.com/graphql"

---@param owner_type string
---@return string
local function items_query(owner_type)
    return ([[
query($owner: String!, $number: Int!, $status: String!, $cursor: String) {
  owner: %s(login: $owner) {
    projectV2(number: $number) {
      items(first: 100, after: $cursor, orderBy: {field: POSITION, direction: ASC}) {
        pageInfo { hasNextPage endCursor }
        nodes {
          status: fieldValueByName(name: $status) {
            ... on ProjectV2ItemFieldSingleSelectValue { name }
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
    local repository = config.repository.owner .. "/" .. config.repository.repo
    local epic_label = vim.tbl_get(config, "labels", "kind", "epic")

    local nodes = queue.paginate(function(cursor)
        local response = queue.post(tracker, URL, "Bearer {{VAR}}", items_query(project.ownerType), {
            owner = project.owner,
            number = project.number,
            status = status.field,
            cursor = cursor,
        })
        local items = vim.tbl_get(queue.data(URL, response), "owner", "projectV2", "items")
        if not items then
            util.refuse(("GitHub Project %s/%d not found"):format(project.owner, project.number))
        end
        return items
    end)

    local result = {}
    for _, node in ipairs(nodes) do
        local content = node.content
        if
            vim.tbl_get(node, "status", "name") == status.values.todo
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
                mention = marker,
                marker = marker,
                title = content.title,
                url = content.url,
                kind = content.__typename == "PullRequest" and { kind = "pr" } or M.kind(content, epic_label),
            }
            table.insert(result, item)
        end
    end
    return result
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
