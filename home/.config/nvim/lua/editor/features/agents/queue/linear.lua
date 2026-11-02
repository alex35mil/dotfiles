-- Todo work of a Linear team: Projects (Epics) first, then issues (Tasks in
-- a Project, Gigs without one), each in Linear's manual order.

local util = require("editor.features.agents.util")
local queue = require("editor.features.agents.queue")

local M = {}

local URL = "https://api.linear.app/graphql"

local PROJECTS = [[
query($team: String!, $status: String!, $cursor: String) {
  projects(first: 100, after: $cursor, filter: {
    status: { name: { eq: $status } },
    accessibleTeams: { some: { name: { eq: $team } } }
  }) {
    pageInfo { hasNextPage endCursor }
    nodes { id name url sortOrder }
  }
}]]

local ISSUES = [[
query($team: String!, $state: String!, $cursor: String) {
  issues(first: 100, after: $cursor, filter: {
    team: { name: { eq: $team } },
    state: { name: { eq: $state } }
  }) {
    pageInfo { hasNextPage endCursor }
    nodes { id identifier title url sortOrder project { id name url } }
  }
}]]

---@param tracker QueueTracker
---@return QueueItem[]
function M.load(tracker)
    local config = tracker.config
    local authorization = M.authorization(tracker)

    ---@param query string
    ---@param variables table
    ---@param field string
    local function fetch(query, variables, field)
        local nodes = queue.paginate(function(cursor)
            local response =
                queue.post(tracker, URL, authorization, query, vim.tbl_extend("force", variables, { cursor = cursor }))
            return queue.data(URL, response)[field]
        end)
        table.sort(nodes, function(a, b)
            return a.sortOrder < b.sortOrder
        end)
        return nodes
    end

    local result = {}
    for _, project in
        ipairs(fetch(PROJECTS, { team = config.team, status = config.statuses.projects.todo }, "projects"))
    do
        ---@type QueueItem
        local item = {
            id = "linear:project:" .. project.id,
            mention = project.url,
            title = project.name,
            url = project.url,
            kind = { kind = "epic" },
        }
        table.insert(result, item)
    end
    for _, issue in ipairs(fetch(ISSUES, { team = config.team, state = config.statuses.issues.todo }, "issues")) do
        local project = issue.project
        ---@type QueueItem
        local item = {
            id = "linear:issue:" .. issue.id,
            mention = issue.identifier,
            marker = issue.identifier,
            title = issue.title,
            url = issue.url,
            kind = type(project) == "table"
                    and { kind = "task", epic = { mention = project.url, title = project.name } }
                or { kind = "gig" },
        }
        table.insert(result, item)
    end
    return result
end

--- Linear API keys go in the header as is, OAuth tokens as `Bearer`; try
--- the key form first, like pi-af does.
---@param tracker QueueTracker
---@return string
function M.authorization(tracker)
    for _, authorization in ipairs({ "{{VAR}}", "Bearer {{VAR}}" }) do
        local response = queue.post(tracker, URL, authorization, "query { viewer { id } }", {})
        if response.status ~= 401 and response.status ~= 400 then
            queue.data(URL, response)
            return authorization
        end
    end
    util.refuse("Linear rejected " .. tracker.credential)
    error("unreachable")
end

return M
