---@diagnostic disable-next-line: lowercase-global
log = {}

local ERROR = vim.log.levels.ERROR
local WARN = vim.log.levels.WARN
local INFO = vim.log.levels.INFO
local DEBUG = vim.log.levels.DEBUG

---@param message string
function log.info(message)
    vim.notify(message, INFO)
end

---@param message string
function log.warn(message)
    vim.notify(message, WARN)
end

---@param message string
function log.error(message)
    vim.notify(message, ERROR)
end

---@param payload string | number | any
function log.debug(payload)
    local message

    local type = type(payload)

    if type == "string" then
        message = payload
    elseif type == "number" then
        message = tostring(payload)
    else
        message = vim.inspect(payload)
    end

    vim.notify(message, DEBUG)
end
