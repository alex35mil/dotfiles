local M = {}

function M.setup(config)
    config.tsserver.setup {
        on_attach = function(client)
            -- Formatting is handled by conform/prettier
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
    }
end

return M
