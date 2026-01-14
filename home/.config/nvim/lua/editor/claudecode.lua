-- Multi-tab terminal provider for claudecode.nvim
-- Enables independent Claude sessions per tab with broadcast filtering

-- Store terminals separately to avoid deepcopy issues with userdata
local terminals = {} ---@type table<TabID, {terminal: snacks.win, bufnr: number, client_id: string|nil}>
local clients = {} ---@type table<TabID, string>

local M = {
    config = nil,
    original_broadcast = nil,
    broadcast_patched = false,
    initialized = false,
}

-- Expose as read-only properties via metatable to prevent deepcopy traversal
setmetatable(M, {
    __index = function(_, k)
        if k == "terminals" then
            return terminals
        elseif k == "clients" then
            return clients
        end
    end,
    __newindex = function(t, k, v)
        if k == "terminals" or k == "clients" then
            -- Ignore attempts to set these
        else
            rawset(t, k, v)
        end
    end,
    __deepcopy = function()
        -- Return a shallow copy without terminals/clients
        return {
            config = M.config,
            original_broadcast = M.original_broadcast,
            broadcast_patched = M.broadcast_patched,
            initialized = M.initialized,
        }
    end,
})

local fn = {}

function M.init(opts)
    if M.initialized then
        return M
    end
    opts = opts or {}
    M.on_close = opts.on_close
    M.initialized = true
    return M
end

function M.is_available()
    local ok, snacks = pcall(require, "snacks")
    return ok and snacks.terminal ~= nil
end

function M.setup(config)
    M.config = config
    fn.register_autocmds()
    fn.patch_broadcast()
end

function M.open(cmd, env, config, focus)
    local tab_id = vim.api.nvim_get_current_tabpage()
    local tab_term = M.terminals[tab_id]

    if tab_term and fn.is_valid(tab_term) then
        tab_term.terminal:show()
        if focus ~= false then
            fn.focus(tab_term)
        end
        return
    end

    local existing_clients = fn.get_client_ids()
    local term = fn.create_terminal(cmd, env, config, focus)
    if not term then
        return
    end

    M.terminals[tab_id] = {
        terminal = term,
        bufnr = term.buf,
        client_id = nil,
    }

    fn.detect_new_client(tab_id, existing_clients)
end

function M.close()
    local tab_id = vim.api.nvim_get_current_tabpage()
    local tab_term = M.terminals[tab_id]

    if tab_term then
        if tab_term.terminal then
            pcall(function()
                tab_term.terminal:close()
            end)
        end
        M.clients[tab_id] = nil
        M.terminals[tab_id] = nil
    end
end

function M.simple_toggle(cmd, env, config)
    local tab_id = vim.api.nvim_get_current_tabpage()
    local tab_term = M.terminals[tab_id]

    if tab_term and fn.is_valid(tab_term) then
        tab_term.terminal:toggle()
    else
        M.open(cmd, env, config, true)
    end
end

function M.focus_toggle(cmd, env, config)
    local tab_id = vim.api.nvim_get_current_tabpage()
    local tab_term = M.terminals[tab_id]

    if not tab_term or not fn.is_valid(tab_term) then
        M.open(cmd, env, config, true)
        return
    end

    local term_win = tab_term.terminal.win
    local current_win = vim.api.nvim_get_current_win()

    if term_win and vim.api.nvim_win_is_valid(term_win) then
        if current_win == term_win then
            tab_term.terminal:hide()
        else
            vim.api.nvim_set_current_win(term_win)
            vim.cmd("startinsert")
        end
    else
        tab_term.terminal:show()
        fn.focus(tab_term)
    end
end

function M.get_active_bufnr()
    local tab_id = vim.api.nvim_get_current_tabpage()
    local tab_term = M.terminals[tab_id]

    if tab_term and tab_term.bufnr and vim.api.nvim_buf_is_valid(tab_term.bufnr) then
        return tab_term.bufnr
    end
    return nil
end

-- Direct toggle that bypasses plugin's internal state
function M.toggle()
    fn.patch_broadcast()
    fn.register_autocmds()

    local tab_id = vim.api.nvim_get_current_tabpage()
    local tab_term = M.terminals[tab_id]

    local cmd = M.config and M.config.terminal_cmd or "claude"

    local env = {
        ENABLE_IDE_INTEGRATION = "true",
        FORCE_CODE_TERMINAL = "true",
    }

    if M.config and M.config.env then
        env = vim.tbl_extend("force", env, M.config.env)
    end

    local port = nil
    local ok, claudecode = pcall(require, "claudecode")
    if ok and claudecode.state and claudecode.state.port then
        port = claudecode.state.port
    end

    if port then
        env.CLAUDE_CODE_SSE_PORT = tostring(port)
    elseif ok and claudecode.start then
        local success, _ = claudecode.start()
        if success and claudecode.state and claudecode.state.port then
            port = claudecode.state.port
            env.CLAUDE_CODE_SSE_PORT = tostring(port)
        end
    end

    local config = M.config or {}

    if tab_term and fn.is_valid(tab_term) then
        tab_term.terminal:toggle()
    else
        M.open(cmd, env, config, true)
    end
end

--- Private

function fn.register_autocmds()
    vim.api.nvim_create_autocmd("TabClosed", {
        group = vim.api.nvim_create_augroup("ClaudeCodeProvider", { clear = true }),
        callback = fn.cleanup_orphaned,
        desc = "Cleanup Claude terminals on tab close",
    })
end

function fn.patch_broadcast()
    if M.broadcast_patched then
        return
    end

    local server = fn.get_server()
    if not server or not server.broadcast then
        return
    end

    M.original_broadcast = server.broadcast

    server.broadcast = function(event, data)
        local current_tab = vim.api.nvim_get_current_tabpage()
        local client_id = M.clients[current_tab]

        if server.state and server.state.clients then
            -- Check if stored client is still valid
            if client_id and server.state.clients[client_id] then
                return server.send(server.state.clients[client_id], event, data)
            end

            -- Stored client invalid - try to find the current one
            local tab_term = M.terminals[current_tab]
            if tab_term and fn.is_valid(tab_term) then
                -- Terminal exists but client_id stale, find new client
                for id, client in pairs(server.state.clients) do
                    -- Use first available client for this tab (reconnected client)
                    M.clients[current_tab] = id
                    if tab_term then
                        tab_term.client_id = id
                    end
                    return server.send(client, event, data)
                end
                return false
            end
        end

        return M.original_broadcast(event, data)
    end

    M.broadcast_patched = true
end

function fn.get_client_ids()
    local ok, claudecode = pcall(require, "claudecode")
    if
        ok
        and claudecode.state
        and claudecode.state.server
        and claudecode.state.server.state
        and claudecode.state.server.state.clients
    then
        return vim.tbl_keys(claudecode.state.server.state.clients)
    end
    return {}
end

function fn.get_server()
    local ok, claudecode = pcall(require, "claudecode")
    if ok and claudecode.state and claudecode.state.server then
        return claudecode.state.server
    end
    return nil
end

function fn.detect_new_client(tab_id, existing_clients)
    local existing_set = {}
    for _, id in ipairs(existing_clients) do
        existing_set[id] = true
    end

    local attempts = 0
    local max_attempts = 100
    local interval = 100

    local function check()
        attempts = attempts + 1
        local current_clients = fn.get_client_ids()

        for _, client_id in ipairs(current_clients) do
            if not existing_set[client_id] then
                M.clients[tab_id] = client_id
                if M.terminals[tab_id] then
                    M.terminals[tab_id].client_id = client_id
                end
                return
            end
        end

        if attempts < max_attempts then
            vim.defer_fn(check, interval)
        end
    end

    vim.defer_fn(check, interval)
end

function fn.create_terminal(cmd, env, config, focus)
    local tab_id = vim.api.nvim_get_current_tabpage()
    local opts = fn.build_opts(config, nil, focus, tab_id)

    local env_prefix = string.format("CLAUDE_TAB_ID=%d", tab_id)
    if env and env.CLAUDE_CODE_SSE_PORT then
        env_prefix = env_prefix .. " CLAUDE_CODE_SSE_PORT=" .. env.CLAUDE_CODE_SSE_PORT
    end

    local unique_cmd = env_prefix .. " " .. cmd .. " --ide"

    local ok, term = pcall(Snacks.terminal, unique_cmd, opts)
    if ok and term then
        return term
    end
    return nil
end

function fn.build_opts(config, env, focus, tab_id)
    local should_focus = focus ~= false

    local win_opts = vim.tbl_deep_extend("force", {
        position = config.split_side or "right",
        width = config.split_width_percentage or 0.35,
        on_close = function()
            M.clients[tab_id] = nil
            M.terminals[tab_id] = nil
            if M.on_close then
                M.on_close(tab_id)
            end
        end,
    }, config.snacks_win_opts or {})

    local opts = {
        key = "claude_tab_" .. tostring(tab_id),
        cwd = config.cwd or vim.fn.getcwd(),
        start_insert = should_focus,
        auto_insert = should_focus,
        auto_close = true,
        win = win_opts,
    }

    if env and next(env) then
        opts.env = env
    end

    return opts
end

function fn.is_valid(tab_term)
    if not tab_term or not tab_term.terminal then
        return false
    end
    if not tab_term.bufnr or not vim.api.nvim_buf_is_valid(tab_term.bufnr) then
        return false
    end
    return true
end

function fn.focus(tab_term)
    local win = tab_term.terminal.win
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
        vim.cmd("startinsert")
    end
end

function fn.cleanup_orphaned()
    local active_tabs = vim.api.nvim_list_tabpages()
    local active_set = {}
    for _, tab in ipairs(active_tabs) do
        active_set[tab] = true
    end

    for tab_id, tab_term in pairs(M.terminals) do
        if not active_set[tab_id] then
            if tab_term.terminal then
                pcall(function()
                    tab_term.terminal:close()
                end)
            end
            M.clients[tab_id] = nil
            M.terminals[tab_id] = nil
        end
    end
end

return M
