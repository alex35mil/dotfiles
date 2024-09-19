local fn = {}

NVZenMode = {
    "folke/zen-mode.nvim",
    keys = function()
        return {
            { NVKarabiner["<D-m>"], fn.toggle_normal, desc = "Toggle zen mode", mode = { "n", "i", "v" } },
            { "<D-S-m>", fn.toggle_maximized, desc = "Toggle maximized zen mode", mode = { "n", "i", "v" } },
            { "<M-m>", fn.deactivate, desc = "Quit zen mode", mode = { "n", "i", "v" } },
        }
    end,
    opts = {
        backdrop = 1,
        height = 1,
    },
}

function NVZenMode.is_active()
    local zenmode = require("zen-mode.view")

    local is_open = zenmode.is_open()

    if is_open == nil then
        return false
    else
        return is_open
    end
end

function NVZenMode.ensure_deacitvated()
    if NVZenMode.is_active() then
        fn.deactivate()
        return true
    else
        return false
    end
end

local ZenWinStatus = {
    normal = "NORMAL",
    maximized = "MAXIMIZED",
}

local ZenWinStatusKey = {
    current = "zen_mode_current_status",
    previous = "zen_mode_previous_status",
}

function ZenWinStatus.get(key)
    local winid = vim.api.nvim_get_current_win()
    return vim.w[winid][key]
end

function ZenWinStatus.set(winid, key, status)
    vim.w[winid][key] = status
end

function ZenWinStatus.width(status)
    if status == ZenWinStatus.normal then
        return NVWindows.default_width
    elseif status == ZenWinStatus.maximized then
        return NVWindows.maximized_width
    else
        vim.api.nvim_err_writeln("Unexpected zen window status: " .. status)
    end
end

function fn.toggle_normal()
    fn.toggle({ status = ZenWinStatus.normal })
end

function fn.toggle_maximized()
    fn.toggle({ status = ZenWinStatus.maximized })
end

function fn.toggle(opts)
    local plugin = require("zen-mode")

    if not NVZenMode.is_active() then
        local params = {
            window = { width = ZenWinStatus.width(opts.status) },
            on_open = function(winid)
                ZenWinStatus.set(winid, ZenWinStatusKey.current, opts.status)
            end,
        }

        plugin.open(params)
    else
        -- Here, I want to handle a specific scenario when I open Zen mode at normal width,
        -- and need to maximize the buffer temporarily (e.g., to check a long line),
        -- then, to return to the normal-width Zen mode without leaving it.
        local current_status = ZenWinStatus.get(ZenWinStatusKey.current)
        local previous_status = ZenWinStatus.get(ZenWinStatusKey.previous)

        if opts.status == ZenWinStatus.maximized and current_status == ZenWinStatus.normal then
            fn.deactivate()

            local params = {
                window = { width = ZenWinStatus.width(ZenWinStatus.maximized) },
                on_open = function(winid)
                    ZenWinStatus.set(winid, ZenWinStatusKey.current, ZenWinStatus.maximized)
                    ZenWinStatus.set(winid, ZenWinStatusKey.previous, ZenWinStatus.normal)
                end,
            }

            plugin.open(params)
        elseif
            (
                (opts.status == ZenWinStatus.maximized and current_status == ZenWinStatus.maximized)
                or (opts.status == ZenWinStatus.normal and current_status == ZenWinStatus.maximized)
            ) and previous_status == ZenWinStatus.normal
        then
            fn.deactivate()

            local params = {
                window = { width = ZenWinStatus.width(ZenWinStatus.normal) },
                on_open = function(winid)
                    ZenWinStatus.set(winid, ZenWinStatusKey.current, ZenWinStatus.normal)
                    ZenWinStatus.set(winid, ZenWinStatusKey.previous, nil)
                end,
            }

            plugin.open(params)
        else
            fn.deactivate()
        end
    end
end

function fn.activate(opts)
    if not NVZenMode.is_active() then
        local plugin = require("zen-mode")

        local params = {
            on_open = function(winid)
                opts.winid = winid
                fn.set_zen_mode_maximized_on_window(opts)
            end,
        }

        if opts.maximized then
            params.window = { width = NVWindows.maximized_width }
        end

        plugin.toggle(params)
    end
end

function fn.deactivate()
    if not NVZenMode.is_active() then
        return
    end

    local plugin = require("zen-mode")

    local zen_buf = vim.api.nvim_get_current_buf()

    plugin.toggle()

    local current_buf = vim.api.nvim_get_current_buf()

    if current_buf == zen_buf then
        return
    end

    vim.api.nvim_set_current_buf(zen_buf)
end

return { NVZenMode }
