---@diagnostic disable-next-line: lowercase-global
log = {}

local ERROR = vim.log.levels.ERROR
local WARN = vim.log.levels.WARN
local INFO = vim.log.levels.INFO
local DEBUG = vim.log.levels.DEBUG
local TRACE = vim.log.levels.TRACE

---@param message string
---@param opts? table
function log.info(message, opts)
    vim.notify(message, INFO, opts)
end

---@param message string
---@param opts? table
function log.warn(message, opts)
    vim.notify(message, WARN, opts)
end

---@param message string|table
---@param opts? table
function log.error(message, opts)
    if type(message) == string then
        ---@cast message string
        vim.notify(message, ERROR, opts)
    else
        vim.notify(vim.inspect(message), ERROR, opts)
    end
end

---@param payload string | number | any
---@param opts? table
function log.debug(payload, opts)
    local message

    local type = type(payload)

    if type == "string" then
        message = payload
    elseif type == "number" then
        message = tostring(payload)
    else
        message = vim.inspect(payload)
    end

    vim.notify(message, DEBUG, vim.tbl_extend("force", { timeout = false }, opts or {}))
end

---@param payload table
---@param opts? table
function log.trace(payload, opts)
    vim.notify(vim.inspect(payload), TRACE, opts)
end
