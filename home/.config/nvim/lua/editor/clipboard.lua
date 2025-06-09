NVClipboard = {}

---@param text string
function NVClipboard.yank(text)
    vim.fn.setreg("+", text)
end
