-- Async process helpers shared by the agent modules.

local M = {}

local Refusal = {}

--- Abort the running task with a message for the user.
---@param message string
function M.refuse(message)
    error(setmetatable({ message = message }, Refusal), 0)
end

--- Run `body` as a coroutine, so `M.exec` and `M.sleep` don't block the UI.
---@param body fun()
function M.async(body)
    local co = coroutine.create(function()
        local ok, err = xpcall(body, function(e)
            if getmetatable(e) == Refusal then
                return e
            end
            return debug.traceback(tostring(e), 2)
        end)
        if ok then
            return
        end
        if getmetatable(err) == Refusal then
            log.warn(err.message)
        else
            log.error(err)
        end
    end)
    M.resume(co)
end

---@param co thread
function M.resume(co, ...)
    local ok, err = coroutine.resume(co, ...)
    if not ok then
        log.error(debug.traceback(co, tostring(err)))
    end
end

--- Run a command; yields inside `M.async`, blocks otherwise.
---@param cmd string[]
---@return vim.SystemCompleted
function M.exec(cmd)
    local co, main = coroutine.running()
    if not co or main then
        return vim.system(cmd, { text = true }):wait()
    end
    vim.system(cmd, { text = true }, function(result)
        vim.schedule(function()
            M.resume(co, result)
        end)
    end)
    return coroutine.yield()
end

---@param cmd string[]
---@param failure string
---@return string stdout
function M.exec_ok(cmd, failure)
    local result = M.exec(cmd)
    if result.code ~= 0 then
        local output = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
        M.refuse(failure .. (output ~= "" and (":\n" .. output) or ""))
    end
    return vim.trim(result.stdout)
end

---@param dir string
---@param args string[]
---@return vim.SystemCompleted
function M.git(dir, args)
    return M.exec(vim.list_extend({ "git", "-C", dir }, args))
end

---@param dir string
---@param args string[]
---@param failure string
---@return string stdout
function M.git_ok(dir, args, failure)
    return M.exec_ok(vim.list_extend({ "git", "-C", dir }, args), failure)
end

---@param path string
---@return string?
function M.git_root(path)
    local result = M.git(path, { "rev-parse", "--show-toplevel" })
    return result.code == 0 and vim.trim(result.stdout) or nil
end

---@param ms integer
function M.sleep(ms)
    local co = coroutine.running()
    vim.defer_fn(function()
        M.resume(co)
    end, ms)
    coroutine.yield()
end

---@param list string[]
---@param n integer
---@return string[]
function M.head(list, n)
    if #list <= n then
        return list
    end
    local result = vim.list_slice(list, 1, n)
    table.insert(result, ("… and %d more"):format(#list - n))
    return result
end

return M
