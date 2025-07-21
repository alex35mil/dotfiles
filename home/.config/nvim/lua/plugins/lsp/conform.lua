NVConform = {
    "stevearc/conform.nvim",
    dependencies = {
        "mason-org/mason.nvim",
    },
    opts = {
        default_format_opts = {
            lsp_format = "fallback",
        },
    },
}

---@param bufid BufID | nil
function NVConform.format(bufid)
    bufid = bufid or vim.api.nvim_get_current_buf()
    require("conform").format({ bufnr = bufid })
end

return { NVConform }
