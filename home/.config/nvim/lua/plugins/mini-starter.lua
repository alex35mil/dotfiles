NVMiniStarter = {
    "echasnovski/mini.starter",
    opts = function()
        local project = NVFS.root({ capitalize = true })

        local item = function(name, action, section)
            return { name = name, action = action, section = section }
        end

        local items = {}

        table.insert(items, function()
            if NVLazy.anything_missing() then
                return item("Install plugins", NVLazy.install, project)
            else
                return nil
            end
        end)

        if NVPersistence.has_session() then
            table.insert(items, item("Restore session", NVPersistence.restore, project))
        end

        table.insert(items, item("Browse project", NVTelescope.open_file_browser, project))

        table.insert(items, item("Quit", "qa", project))

        local config = {
            evaluate_single = false,
            header = "",
            items = items,
        }

        return config
    end,
    config = function(_, config)
        -- close Lazy and re-open when starter is ready
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniStarterOpened",
                callback = function()
                    require("lazy").show()
                end,
            })
        end

        local starter = require("mini.starter")

        starter.setup(config)

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniStarterOpened",
            callback = function()
                NVLualine.hide_tabline()

                local starter_bufid = vim.api.nvim_get_current_buf()

                vim.api.nvim_create_autocmd("BufWipeout", {
                    callback = function(args)
                        local bufid = args.buf

                        if bufid == starter_bufid then
                            NVLualine.rename_tab("editor")
                            NVLualine.show_tabline()
                            NVNoNeckPain.enable()
                        end
                    end,
                })
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            once = true,
            pattern = "MiniStarterOpened",
            callback = NVLualine.hide_tabline,
        })

        vim.api.nvim_create_autocmd("User", {
            once = true,
            pattern = "LazyVimStarted",
            callback = function(ev)
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                starter.config.footer = "  in " .. ms .. "ms"
                if vim.bo[ev.buf].filetype == "ministarter" then
                    pcall(starter.refresh)
                end
            end,
        })
    end,
}

function NVMiniStarter.is_active()
    return vim.bo.filetype == "ministarter"
end

function NVMiniStarter.refresh()
    require("mini.starter").refresh()
end

return { NVMiniStarter }
