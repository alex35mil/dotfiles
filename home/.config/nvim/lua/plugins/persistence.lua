NVPersistence = {}

function NVPersistence.autocmds()
    vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
            local mode = vim.fn.mode()

            if mode == "i" or mode == "v" then
                NVKeys.send("<Esc>", { mode = "x" })
            end

            -- TODO: Complete this list
            NVLazy.ensure_hidden()
            NVNoice.ensure_hidden()
            NVZenMode.ensure_deacitvated()
            NVDiffview.ensure_all_hidden()
            NVNoNeckPain.disable()
        end,
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceLoadPost",
        callback = function()
            NVNoNeckPain.reload()
        end,
    })
end

function NVPersistence.has_session()
    local plugin = require("persistence")

    local sessions = plugin.list()
    local current_session = plugin.current()

    for _, session in ipairs(sessions) do
        if session == current_session then
            return true
        end
    end

    return false
end

function NVPersistence.restore()
    require("persistence").load()
end

return {}
