NVClipboard = {}

function NVClipboard.yank(text)
    vim.fn.setreg("+", text)
end
