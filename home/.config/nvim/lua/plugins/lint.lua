local M = {}

function M.setup()
    local plugin = require "lint"
    plugin.linters_by_ft = {}
end

function M.keymaps()
    K.map { "<M-l>", "Lint", M.lint, mode = "n" }
end

function M.lint()
    local plugin = require "lint"

    plugin.try_lint()
    plugin.try_lint("typos")
end

return M
