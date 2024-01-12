local M = {}

function M.setup(config)
    config.jsonls.setup {
        init_options = {
            provideFormatter = true,
        },
    }
end

return M
