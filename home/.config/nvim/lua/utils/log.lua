---@diagnostic disable-next-line: lowercase-global
log = {}

-- Can be changed from cmdline to enable/disable logging
LOG = "debug" --- @type "trace" | "debug" | "info" | "warn" | "error"

local ERROR = vim.log.levels.ERROR
local WARN = vim.log.levels.WARN
local INFO = vim.log.levels.INFO
local DEBUG = vim.log.levels.DEBUG
local TRACE = vim.log.levels.TRACE

local level_map = {
    trace = TRACE,
    debug = DEBUG,
    info = INFO,
    warn = WARN,
    error = ERROR,
}

---@alias payload string | number | any

---@param payload payload
---@return string
local function message(payload)
    local message

    local type = type(payload)

    if type == "string" then
        message = payload
    elseif type == "number" then
        message = tostring(payload)
    else
        message = vim.inspect(payload)
    end

    return message
end

local function dispatch(payload, level, opts)
    local threshold = level_map[LOG]

    if not threshold then
        print("[ERROR] Unexpected LOG value. Using INFO.")
        threshold = INFO
    end

    if level < threshold then
        return
    end

    if level == TRACE or level == DEBUG then
        opts = vim.tbl_extend("force", { timeout = false }, opts or {})
    end

    vim.notify(message(payload), level, opts)
end

---@param payload payload
---@param opts? table
function log.info(payload, opts)
    dispatch(payload, INFO, opts)
end

---@param payload payload
---@param opts? table
function log.warn(payload, opts)
    dispatch(payload, WARN, opts)
end

---@param payload payload
---@param opts? table
function log.error(payload, opts)
    dispatch(payload, ERROR, opts)
end

---@param payload payload
---@param opts? table
function log.debug(payload, opts)
    dispatch(payload, DEBUG, opts)
end

---@param payload payload
---@param opts? table
function log.trace(payload, opts)
    dispatch(payload, TRACE, opts)
end
