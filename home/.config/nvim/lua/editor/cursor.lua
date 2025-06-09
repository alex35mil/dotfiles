NVCursor = {}

---@alias Cursor {win: WinID, pos: [Row, Col]}

---@return Cursor
function NVCursor.get()
    local win = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_cursor(0)

    return { win = win, pos = pos }
end

---@param cursor Cursor
function NVCursor.set(cursor)
    vim.api.nvim_set_current_win(cursor.win)
    vim.api.nvim_win_set_cursor(cursor.win, cursor.pos)
end

function NVCursor.shake()
    local cursor = vim.api.nvim_win_get_cursor(0)

    local cur_line = cursor[1]
    local cur_col = cursor[2]

    local direction

    if cur_col > 0 then
        direction = "Left"
    elseif cur_line > 1 then
        direction = "Up"
    else
        local total_lines = vim.api.nvim_buf_line_count(0)

        if cur_line < total_lines then
            direction = "Down"
        else
            local lines = vim.api.nvim_buf_get_lines(0, cur_line - 1, cur_line, false)
            local line = lines[1]

            if cur_col < #line - 1 then
                direction = "Right"
            end
        end
    end

    if not direction then
        return nil
    end

    vim.cmd.execute([["normal \<]] .. direction .. [[>"]])

    vim.wait(1000, function()
        local next_cursor = vim.api.nvim_win_get_cursor(0)
        local next_line = next_cursor[1]
        local next_col = next_cursor[2]
        local moved = next_line ~= cur_line or next_col ~= cur_col

        return moved
    end, 10, false)

    return function()
        vim.api.nvim_win_set_cursor(0, cursor)
    end
end
