local M = {}

function M.zenmode()
    local filetree = require "utils/filetree"
    local zenmode = require "utils/zenmode"
    local view = require "utils/view"

    if not filetree.is_active() then
        zenmode.toggle()
    else
        local tab_windows = view.get_tab_windows()

        if tab_windows == nil then
            vim.api.nvim_err_writeln "Failed to find windows of the current tab"
            return
        end

        if #tab_windows == 1 then
            print "Zen mode is not available for the file tree"
            return
        end

        if #tab_windows == 2 then
            for _, win in ipairs(tab_windows) do
                local buf = vim.api.nvim_win_get_buf(win)
                if not filetree.is_tree(buf) then
                    vim.api.nvim_set_current_win(win)
                    zenmode.activate()
                    return
                end
            end
        else
            print "Zen mode is not available for the file tree. Select different window to activate zen mode."
        end
    end
end

function M.close_buffer()
    local current_buf = vim.api.nvim_get_current_buf()

    local filetree = require "utils/filetree"

    if filetree.is_tree(current_buf) then
        vim.api.nvim_err_writeln "To hide filetree, use corresponding keymap"
        return
    end

    local zenmode = require "utils/zenmode"

    if zenmode.is_active() then
        zenmode.deactivate()
    end

    local current_buf_info = vim.fn.getbufinfo(current_buf)[1]

    if current_buf_info == nil then
        vim.api.nvim_err_writeln "Can't get current buffer info"
        return
    end

    if current_buf_info.name == "" and current_buf_info.changed == 1 then
        vim.api.nvim_err_writeln "The buffer needs to be saved first"
        return
    end

    local mode = vim.fn.mode()

    if mode ~= "n" then
        local keys = require "utils/keys"
        keys.send_keys "<Esc>"
    end

    local view = require "utils/view"

    local tab_windows = view.get_tab_windows_without_filetree()

    if #tab_windows > 1 then
        vim.cmd "silent! write"

        for _, win in ipairs(tab_windows) do
            local buf = vim.api.nvim_win_get_buf(win)
            if buf == current_buf then
                vim.cmd.close()
                return
            end
        end

        vim.cmd.bdelete(current_buf)
    else
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })

        local next_buf = nil

        for _, buf in ipairs(bufs) do
            if buf.bufnr ~= current_buf and not filetree.is_tree(buf.bufnr) then
                next_buf = buf.bufnr
                break
            end
        end

        if next_buf ~= nil then
            vim.cmd "silent! write"
            vim.api.nvim_set_current_buf(next_buf)
            vim.cmd.bdelete(current_buf)
        else
            local empty_buf = vim.api.nvim_create_buf(true, false)

            if empty_buf == 0 then
                vim.api.nvim_err_writeln "Failed to create empty buffer"
                vim.cmd "silent! write"
                vim.cmd.bdelete(current_buf)
            else
                vim.cmd "silent! write"
                vim.api.nvim_set_current_buf(empty_buf)
                vim.cmd.bdelete(current_buf)
            end
        end
    end
end

function M.close_all_bufs_except_current(opts)
    local filetree = require "utils/filetree"

    local incl_unsaved = opts.incl_unsaved

    local current_buf = vim.api.nvim_get_current_buf()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })

    vim.cmd "silent! wa"

    for _, buf in ipairs(bufs) do
        if buf.bufnr ~= current_buf and not filetree.is_tree(buf.bufnr) then
            local unnamed_modified = buf.name == "" and buf.changed == 1

            if not unnamed_modified then
                vim.cmd.bdelete(buf.bufnr)
            elseif unnamed_modified and incl_unsaved then
                vim.cmd("bdelete! " .. buf.bufnr)
            end
        end
    end

    local view = require "utils/view"

    local current_win = vim.api.nvim_get_current_win()
    local wins = view.get_tab_windows_without_filetree()

    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)

        if win ~= current_win and buf_name ~= "" then
            vim.api.nvim_win_close(win, false)
        end
    end
end

function M.quit()
    local mode = vim.fn.mode()

    if mode == "i" or mode == "v" then
        local keys = require "utils/keys"
        keys.send_keys "<Esc>"
    end

    local zenmode = require "utils/zenmode"

    if zenmode.is_active() then
        zenmode.deactivate()
    end

    -- NOTE: Not `wqa` due to toggleterm issue
    vim.cmd "wa"
    vim.cmd "qa"
end

return M
