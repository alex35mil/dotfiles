local M = {}
local m = {}

function M.keymaps()
    K.map { "<D-v>", "Paste text", m.paste, mode = "t", expr = true }
    K.map { "<D-Esc>", "Exit terminal mode", "<C-\\><C-n>", mode = "t" }
end

-- Private

function m.paste()
    local content = vim.fn.getreg("*")
    content = vim.api.nvim_replace_termcodes(content, true, true, true)
    vim.api.nvim_feedkeys(content, "t", true)
end

return M
