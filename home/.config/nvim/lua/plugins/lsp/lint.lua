NVLint = {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
        local lint = require("lint")

        for name, linter in pairs(opts.linters) do
            if type(linter) == "table" and type(lint.linters[name]) == "table" then
                ---@diagnostic disable-next-line: param-type-mismatch
                lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
                if type(linter.prepend_args) == "table" then
                    lint.linters[name].args = lint.linters[name].args or {}
                    vim.list_extend(lint.linters[name].args, linter.prepend_args)
                end
            else
                lint.linters[name] = linter
            end
        end

        lint.linters_by_ft = opts.linters_by_ft or {}

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("lint", { clear = true }),
            callback = function()
                if vim.bo.modifiable then
                    lint.try_lint()
                end
            end,
        })
    end,
}

return { NVLint }
