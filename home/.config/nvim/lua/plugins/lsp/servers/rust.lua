local M = {}

function M.setup()
    vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {},
        -- LSP configuration
        server = {
            on_attach = function(_client, _bufnr)
                -- TODO: Add keymaps here
            end,
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = {
                        command = "clippy",
                    },
                },
            },
        },
        -- DAP configuration
        dap = {},
    }
end

return M
