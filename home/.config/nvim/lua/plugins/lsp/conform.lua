NVConform = {
    "stevearc/conform.nvim",
    dependencies = {
        "mason-org/mason.nvim",
    },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettierd", "prettier", stop_after_first = true },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
    },
}

---@param bufid BufID
function NVConform.format(bufid)
    require("conform").format({ bufnr = bufid })
end

return { NVConform }
