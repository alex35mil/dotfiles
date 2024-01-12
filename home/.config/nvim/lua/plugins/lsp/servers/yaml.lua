local M = {}

function M.setup(config)
    config.yamlls.setup {
        settings = {
            yaml = {
                format = { enable = false },
                keyOrdering = false,
            },
        },
    }
end

return M
