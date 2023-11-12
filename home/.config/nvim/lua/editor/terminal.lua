local M = {}
local m = {}

function M.keymaps()
    K.map { "<D-v>", "Paste text", m.paste, mode = "t", expr = true }
    K.map { "<D-Esc>", "Exit terminal mode", "<C-\\><C-n>", mode = "t" }
end

-- Private

function m.paste()
    local content = vim.fn.getreg("*")
    vim.api.nvim_put({ content }, "", true, true)
end

return M
