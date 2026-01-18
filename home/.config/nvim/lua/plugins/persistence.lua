NVPersistence = {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
}

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
            NVMason.ensure_hidden()
            NVNoice.ensure_hidden()
            NVFocus.ensure_deacitvated()
            NVSZoom.ensure_deactivated()
            NVSLazygit.ensure_hidden()
            NVDiffview.ensure_all_hidden()
            NVGitCommit.ensure_hidden()

            NVTabs.save_labels()

            -- Switch to first tab so persistence saves under
            -- main repo's cwd in case we're on a worktree tab
            vim.cmd("tabfirst")
        end,
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceLoadPost",
        callback = function()
            NVTabs.restore_labels()
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

return { NVPersistence }
