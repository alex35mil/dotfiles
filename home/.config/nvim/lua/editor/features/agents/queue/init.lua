-- The source's queued (Todo) tracker work, read from the tracker configured
-- in `<source>/.project/integrations.json`, with the credential the tracker's
-- MCP registration names.

---@class QueueParent
---@field mention string How a workflow command names the Epic.
---@field marker string? Short reference, when the tracker has one.
---@field title string

---@alias QueueKind
---| { kind: "epic" }
---| { kind: "task", epic: QueueParent }
---| { kind: "gig" }
---| { kind: "pr" } An incoming pull request.
---| { kind: "unclassified" } Top-level work in a tracker with no Epic Kind label configured to tell an Epic from a Gig.

---@class QueueItem
---@field id string Stable identity, stored as the agent's `agent.issue`.
---@field mention string How a workflow command names the item.
---@field marker string? Short reference, when the tracker has one (`#12`, `ENG-42`).
---@field title string
---@field url string
---@field kind QueueKind

---@class QueueTracker
---@field source string
---@field config table The `tracker` object of `integrations.json`.
---@field credential string Name of the environment variable holding the token.

local util = require("editor.features.agents.util")

local M = {}

local INTEGRATIONS = ".project/integrations.json"

--- Todo items in tracker order. Refuses when the tracker can't be read.
---@param source string
---@return QueueItem[]
function M.load(source)
    local file = vim.fs.joinpath(source, INTEGRATIONS)
    if not vim.uv.fs_stat(file) then
        util.refuse("No tracker configured: " .. file .. " doesn't exist")
    end
    local config = util.read_json(file)
    local tracker = type(config) == "table" and config.tracker or nil
    if type(tracker) ~= "table" or type(tracker.mcpServer) ~= "string" then
        util.refuse("No tracker configured in " .. file)
    end

    ---@type QueueTracker
    local queue_tracker = { source = source, config = tracker, credential = M.credential(source, tracker.mcpServer) }
    if tracker.provider == "github" then
        return require("editor.features.agents.queue.github").load(queue_tracker)
    elseif tracker.provider == "linear" then
        return require("editor.features.agents.queue.linear").load(queue_tracker)
    end
    util.refuse("Unsupported tracker provider in " .. file .. ": " .. tostring(tracker.provider))
    error("unreachable")
end

--- The environment variable the MCP registration authorizes with, from the
--- same settings files pi-af reads (global, then project, then local).
---@param source string
---@param server string
---@return string
function M.credential(source, server)
    local agent_dir = vim.env.PI_CODING_AGENT_DIR and vim.fs.normalize(vim.env.PI_CODING_AGENT_DIR)
        or vim.fs.joinpath(vim.env.HOME, ".pi", "agent")
    local files = {
        vim.fs.joinpath(agent_dir, "mcp.json"),
        vim.fs.joinpath(source, ".agents", "mcp.json"),
        vim.fs.joinpath(source, ".agents", "mcp.local.json"),
    }
    local registration
    for _, file in ipairs(files) do
        if vim.uv.fs_stat(file) then
            local settings = util.read_json(file)
            local servers = type(settings) == "table" and settings.mcpServers or nil
            if type(servers) == "table" and servers[server] ~= nil then
                registration = servers[server]
            end
        end
    end
    if type(registration) ~= "table" then
        util.refuse("MCP server " .. server .. " isn't registered in:\n" .. table.concat(files, "\n"))
    end
    local authorization = type(registration.headers) == "table" and registration.headers.Authorization or nil
    local variable = type(authorization) == "string" and authorization:match("^Bearer %${([%a_][%w_]*)}$")
    if not variable then
        util.refuse("MCP server " .. server .. " has no `Authorization: Bearer ${VAR}` header")
    end
    return variable
end

---@class QueueResponse
---@field status integer HTTP status.
---@field body any Decoded JSON body.

--- POST a GraphQL request with curl, inside the source's mise environment so
--- the credential resolves there and never passes through Neovim.
---@param tracker QueueTracker
---@param url string
---@param authorization string Authorization header, with `{{VAR}}` for the credential.
---@param query string
---@param variables table
---@return QueueResponse
function M.post(tracker, url, authorization, query, variables)
    local var = tracker.credential
    local result = util.exec({
        "mise",
        "exec",
        "-C",
        tracker.source,
        "--",
        "curl",
        "--silent",
        "--show-error",
        "--max-time",
        "20",
        "--variable",
        "%" .. var,
        "--expand-header",
        "Authorization: " .. authorization:gsub("{{VAR}}", "{{" .. var .. "}}"),
        "--header",
        "Content-Type: application/json",
        "--data-binary",
        "@-",
        "--write-out",
        "\n%{http_code}",
        url,
    }, { stdin = vim.json.encode({ query = query, variables = variables }) })

    if result.code ~= 0 then
        local stderr = vim.trim(result.stderr or "")
        if stderr:find("Variable '" .. var .. "' import fail", 1, true) then
            util.refuse(var .. " isn't set in the environment of " .. tracker.source)
        end
        util.refuse("Tracker request failed: " .. stderr)
    end

    local body, status = (result.stdout or ""):match("^(.*)\n(%d+)$")
    if not status then
        util.refuse("Unexpected tracker response from " .. url)
    end
    local ok, decoded = pcall(vim.json.decode, body, { luanil = { object = true, array = true } })
    return {
        status = tonumber(status) --[[@as integer]],
        body = ok and decoded or body,
    }
end

--- The `data` of a successful GraphQL response; refuses otherwise.
---@param url string
---@param response QueueResponse
---@return table
function M.data(url, response)
    local body = response.body
    local errors = type(body) == "table" and body.errors or nil
    if response.status ~= 200 or type(errors) == "table" or type(body) ~= "table" or type(body.data) ~= "table" then
        local messages = {}
        for _, err in ipairs(type(errors) == "table" and errors or {}) do
            table.insert(messages, type(err) == "table" and tostring(err.message) or tostring(err))
        end
        local detail = #messages > 0 and table.concat(messages, "\n") or vim.inspect(body):sub(1, 300)
        util.refuse(("Tracker request to %s failed (HTTP %d):\n%s"):format(url, response.status, detail))
    end
    return body.data
end

--- Fetch every page of a connection. `page` receives the cursor and returns
--- the connection's `nodes` and `pageInfo`.
---@param page fun(cursor: string?): {nodes: table[], pageInfo: {hasNextPage: boolean, endCursor: string?}}
---@return table[]
function M.paginate(page)
    local nodes, cursor = {}, nil
    for _ = 1, 50 do
        local connection = page(cursor)
        vim.list_extend(nodes, connection.nodes)
        if not connection.pageInfo.hasNextPage then
            return nodes
        end
        cursor = connection.pageInfo.endCursor
    end
    util.refuse("Tracker returned too many pages")
    error("unreachable")
end

--- The workflow command that starts `item`, naming it by reference and
--- title, with a trailing space so comments can follow; nil when its kind
--- is unknown.
---@param item QueueItem
---@return string?
function M.command(item)
    local subject = item.mention .. " " .. item.title
    local kind = item.kind
    if kind.kind == "epic" then
        return "/epic " .. subject .. " "
    elseif kind.kind == "task" then
        return "/task " .. subject .. " (Epic " .. kind.epic.mention .. ") "
    elseif kind.kind == "gig" then
        return "/gig " .. subject .. " "
    elseif kind.kind == "pr" then
        return "/pr " .. subject .. " "
    elseif kind.kind == "unclassified" then
        return nil
    end
    error("unknown queue kind: " .. vim.inspect(kind))
end

local NAME_MAX = 48

--- Agent directory name: `<marker>-<title slug>`, cut at a word.
---@param item QueueItem
---@return string
function M.agent_name(item)
    local name = M.slugify((item.marker or "") .. " " .. item.title)
    if #name > NAME_MAX then
        name = name:sub(1, NAME_MAX):gsub("%-[^%-]*$", "")
    end
    return name
end

--- Agent label: the marker and the full title.
---@param item QueueItem
---@return string
function M.agent_label(item)
    return item.marker and (item.marker .. " " .. item.title) or item.title
end

---@param value string
---@return string
function M.slugify(value)
    local slug = value:lower():gsub("[^a-z0-9]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
    return slug
end

return M
