local M = {}

function M.setup()
    -- Disabling virtual lines by deafult as they are too annoying when editing
    vim.diagnostic.config({ virtual_lines = false })
    require("lsp_lines").setup()
end

return M
