local fn = {}

NVLazy = {}

function NVLazy.ensure_hidden()
    if fn.is_active() then
        fn.close()
        return true
    else
        return false
    end
end

function NVLazy.anything_missing()
    local plugins = require("lazy.core.config").plugins

    for _, plugin in pairs(plugins) do
        local installed = plugin._.installed
        local needs_build = plugin._.build

        if not installed or needs_build then
            return true
        end
    end

    return false
end

function NVLazy.install()
    require("lazy").install()
end

function fn.is_active()
    return vim.bo.filetype == "lazy"
end

function fn.close()
    NVKeys.send("q", { mode = "x" })

    vim.schedule(function()
        if NVMiniStarter.is_active() then
            NVMiniStarter.refresh()
        end
    end)
end

return {}
