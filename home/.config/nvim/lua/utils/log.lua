---@diagnostic disable-next-line: lowercase-global
log = {}

--- @alias LogLevel "trace" | "debug" | "info" | "warn" | "error"
--- "trace" - for extensive debugging of specific issues - should be commited and disabled by default
--- "debug" - for temporary debug logging "right here, right now" - shouldn't be commited, but enabled by default
--- "info"+ - general user-level alerts

local default = "debug" ---@type LogLevel

local LEVEL = default ---@type LogLevel

function log.keymaps()
    K.map({
        "<M-l>t",
        "LOG: Set log level to `trace`",
        function()
            LEVEL = "trace"
        end,
        mode = "n",
    })

    K.map({
        "<M-l>i",
        "LOG: Set log level to `info`",
        function()
            LEVEL = "info"
        end,
        mode = "n",
    })

    K.map({
        "<M-l>r",
        "LOG: Reset log level",
        function()
            LEVEL = default
        end,
        mode = "n",
    })
end

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
    local threshold = level_map[LEVEL]

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
