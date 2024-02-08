local M = {}

M.scratchpad_filename = "SIDENOTES"
M.scratchpad_filetype = "md"

function M.setup()
    local plugin = require "no-neck-pain"
    local windows = require "editor.windows"

    local sideBufOpts = {
        enabled = true,
        bo = {
            filetype = M.scratchpad_filetype,
            buftype = "nofile",
            bufhidden = "hide",
            buflisted = false,
            swapfile = false,
        },
    }

    plugin.setup {
        width = windows.default_width,

        autocmds = {
            enableOnVimEnter = vim.g.neovide,
            enableOnTabEnter = false,
            reloadOnColorSchemeChange = false,
        },

        mappings = {
            enabled = false,
        },

        buffers = {
            left = sideBufOpts,
            right = sideBufOpts,
            scratchPad = {
                enabled = true,
                fileName = M.scratchpad_filename,
            },
        },

        integrations = {
            NeoTree = {
                reopen = false,
            },
        },
    }
end

function M.increase_window_width()
    vim.cmd "NoNeckPainWidthUp"
end

function M.decrease_window_width()
    vim.cmd "NoNeckPainWidthDown"
end

function M.set_default_window_width()
    local windows = require "editor.windows"
    vim.cmd("NoNeckPainResize " .. windows.default_width)
end

function M.get_sidenotes()
    local plugin = _G.NoNeckPain

    if not plugin then return nil end

    local state = plugin.state

    if not state then return nil end

    local current_tab = vim.api.nvim_get_current_tabpage()

    local tab = nil

    if state.tabs ~= nil then
        for _, t in ipairs(state.tabs) do
            if t.id == current_tab then
                tab = t
                break
            end
        end
    end

    if not tab then return nil end

    local win = tab.wins.main

    return {
        left = win.left,
        right = win.right,
    }
end

function M.are_sidenotes_visible()
    local sidenotes = M.get_sidenotes()

    if not sidenotes then return false end

    return sidenotes.left ~= nil or sidenotes.right ~= nil
end

function M.ensure_sidenotes_hidden()
    if M.are_sidenotes_visible() then
        vim.cmd "NoNeckPain"
    end
end

function M.disable()
    local plugin = _G.NoNeckPain
    plugin.disable()
end

function M.enable()
    local plugin = _G.NoNeckPain
    plugin.enable()
end

function M.reload()
    local plugin = _G.NoNeckPain
    pcall(plugin.disable)
    plugin.enable()
end

return M
