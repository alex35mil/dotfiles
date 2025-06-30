NVTerminal = {}

local fn = {}

function NVTerminal.keymaps()
    K.map({ "<D-v>", "Paste text", fn.paste, mode = "t", expr = true })
    K.map({ "<S-Esc>", "Exit terminal mode", "<C-\\><C-n>", mode = "t" })
    K.map({ "<D-Up>", "Lazygit: Scroll up main panel", "<C-\\><C-u>", mode = "t" })
    K.map({ "<D-Down>", "Lazygit: Scroll down main panel", "<C-\\><C-d>", mode = "t" })
end

function fn.paste()
    local content = vim.fn.getreg("*")
    content = vim.api.nvim_replace_termcodes(content, true, true, true)
    vim.api.nvim_feedkeys(content, "t", true)
end
