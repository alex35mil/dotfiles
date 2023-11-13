local M = {}
local m = {}

function M.keymaps()
    K.mapseq { "<M-d>w", "DEBUG: Print current window and buffer info", m.print_current_window_and_buffer_info, mode = "n" }
    K.mapseq { "<M-d>b", "DEBUG: Print all buffers info", m.print_all_buffers_info, mode = "n" }
end

-- Private

function m.print_window_info(winnr)
    local win_info = vim.api.nvim_win_get_config(winnr)

    print("winnr: " .. winnr)
    print("win info: " .. vim.inspect(win_info))
end

function m.print_buffer_info(bufnr)
    local buf_info = vim.fn.getbufinfo(bufnr)[1]

    print("bufnr: " .. bufnr)
    print("buf info: " .. vim.inspect(buf_info))
end

function m.print_current_window_and_buffer_info()
    local winnr = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_get_current_buf()

    m.print_window_info(winnr)
    m.print_buffer_info(bufnr)
end

function m.print_all_buffers_info()
    local bufs = vim.fn.getbufinfo()

    print("bufs: " .. vim.inspect(bufs))
end

return M
