local M = {}

function M.setup(config)
    local rust_tools = require "rust-tools"

    rust_tools.setup {
        server = {
            cmd = { "rustup", "run", "stable", "rust-analyzer" },
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = {
                        command = "clippy",
                    },
                },
            },
        },
    }
end

return M
