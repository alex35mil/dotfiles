NVDebug = {}

local fn = {}

function NVDebug.keymaps()
    K.map({ "<M-d>w", "DEBUG: Print current window and buffer info", fn.print_current_window_and_buffer_info, mode = "n" })
    K.map({ "<M-d>b", "DEBUG: Print all buffers info", fn.print_all_buffers_info, mode = "n" })
end

---@param data string
function fn.print(data)
    vim.notify(data, vim.log.levels.INFO, { timeout = false })
end

---@param winnr WinID
function fn.print_window_info(winnr)
    local win_info = vim.api.nvim_win_get_config(winnr)
    local cursor_info = vim.api.nvim_win_get_cursor(winnr)

    fn.print("winnr: " .. winnr)
    fn.print("win info: " .. vim.inspect(win_info))
    fn.print("cursor: " .. vim.inspect(cursor_info))
end

---@param bufnr BufID
function fn.print_buffer_info(bufnr)
    local buf_info = vim.fn.getbufinfo(bufnr)[1]

    fn.print("bufnr: " .. bufnr)
    fn.print("buf info: " .. vim.inspect(buf_info))
end

function fn.print_current_window_and_buffer_info()
    local winnr = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_get_current_buf()

    fn.print_window_info(winnr)
    fn.print_buffer_info(bufnr)
end

function fn.print_all_buffers_info()
    local bufs = vim.fn.getbufinfo()

    fn.print("bufs: " .. vim.inspect(bufs))
end
