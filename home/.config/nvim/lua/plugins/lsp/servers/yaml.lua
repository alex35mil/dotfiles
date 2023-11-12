local M = {}

function M.setup(config)
    config.yamlls.setup {
        settings = {
            yaml = {
                keyOrdering = false,
            },
        },
    }
end

return M
