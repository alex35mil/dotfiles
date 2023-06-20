local M = {}

function M.zenmode()
    local filetree = require "utils.filetree"
    local zenmode = require "utils.zenmode"
    local view = require "utils.view"

    if not filetree.is_active() then
        zenmode.toggle()
    elseif zenmode.is_active() then
        zenmode.deactivate()
    else
        local tab_windows = view.get_tab_windows_with_listed_buffers()

        if tab_windows == nil or #tab_windows == 0 then
            vim.api.nvim_err_writeln "No windows available"
            return
        end


        if #tab_windows == 1 then
            -- When there is only one file buffer is visisble,
            -- activating zenmode even if filetree has focus
            local win = tab_windows[1]
            if vim.api.nvim_get_current_win() ~= win then
                vim.api.nvim_set_current_win(win)
            end
            zenmode.activate()
        else
            local current_buf = vim.api.nvim_get_current_buf()

            for _, win in ipairs(tab_windows) do
                local buf = vim.api.nvim_win_get_buf(win)
                if buf == current_buf then
                    zenmode.activate()
                    return
                end
            end

            print "Zen mode is not available for the current window. Select different window to activate zen mode."
        end
    end
end

function M.close_buffer(opts)
    local git = require "utils.git"

    if git.is_lazygit_active() then
        git.close_lazygit()
        return
    end

    local current_git_diff = git.current_diff()

    if current_git_diff ~= nil then
        git.hide_current_diff()
        return
    end

    local lazy = require "utils.lazy"

    if lazy.is_active() then
        lazy.close()
        return
    end

    local mason = require "utils.mason"

    if mason.is_active() then
        mason.close()
        return
    end

    local term = require "utils.terminal"

    local active_term = term.get_active()

    if active_term ~= nil then
        term.hide(active_term)
        return
    end

    local should_close_window = opts.should_close_window

    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local filetree = require "utils.filetree"

    if filetree.is_tree(current_buf) then
        filetree.close()
        return
    end

    local buffers = require "utils.buffers"
    local zenmode = require "utils.zenmode"

    local current_buf_info = buffers.get_buf_info(current_buf)

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
        local keys = require "utils.keys"
        keys.send_in_x_mode "<Esc>"
    end

    local view = require "utils.view"

    local tab_windows = view.get_tab_windows_with_listed_buffers()

    if #tab_windows > 1 and not zenmode.is_active() and should_close_window then
        vim.cmd "silent! write"

        for _, win in ipairs(tab_windows) do
            local buf = vim.api.nvim_win_get_buf(win)
            if buf == current_buf then
                vim.cmd.close()
                return
            end
        end

        if not view.is_other_window_with_buffer(tab_windows, current_win, current_buf) then
            vim.cmd.bdelete(current_buf)
        end
    else
        local bufs = buffers.get_listed_bufs({ sort_lastused = true })

        local next_buf = nil

        for _, buf in ipairs(bufs) do
            if buf.bufnr ~= current_buf then
                next_buf = buf.bufnr
                break
            end
        end

        if next_buf ~= nil then
            vim.cmd "silent! write"
            vim.api.nvim_set_current_buf(next_buf)
            if zenmode.is_active() then
                local parent_win = zenmode.parent_window()

                if parent_win ~= nil then
                    vim.api.nvim_win_set_buf(parent_win, next_buf)
                end

                vim.cmd.bdelete(current_buf)
            elseif not view.is_other_window_with_buffer(tab_windows, current_win, current_buf) then
                vim.cmd.bdelete(current_buf)
            end
        else
            if #tab_windows > 1 and not zenmode.is_active() then
                vim.cmd "silent! write"
                vim.cmd.close()
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
end

function M.close_all_bufs_except_current(opts)
    local filetree = require "utils.filetree"

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

    local view = require "utils.view"

    local current_win = vim.api.nvim_get_current_win()
    local wins = view.get_tab_windows_with_listed_buffers()

    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)

        if win ~= current_win and buf_name ~= "" then
            vim.api.nvim_win_close(win, false)
        end
    end
end

function M.quit()
    local git = require "utils.git"
    local term = require "utils.terminal"
    local zenmode = require "utils.zenmode"
    local filetree = require "utils.filetree"

    local mode = vim.fn.mode()

    if mode == "i" or mode == "v" then
        local keys = require "utils.keys"
        keys.send_in_x_mode "<Esc>"
    end

    git.ensure_diff_hidden()
    term.ensure_hidden()
    filetree.ensure_hidden()
    zenmode.ensure_deacitvated()

    -- NOTE: Not `wqa` due to toggleterm issue
    vim.cmd "wa"
    vim.cmd "qa"
end

return M
