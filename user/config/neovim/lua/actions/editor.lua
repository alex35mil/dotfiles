local M = {}

function M.paste()
    local keys = require "utils.keys"

    local mode = vim.fn.mode()

    if mode == "i" or mode == "c" then
        local paste = vim.o.paste
        local fopts = vim.o.formatoptions

        vim.o.paste = true
        vim.o.formatoptions = fopts:gsub("[crota]", "")

        keys.send("<C-r>+", { mode = "n" })

        vim.defer_fn(
            function()
                vim.o.paste = paste
                vim.o.formatoptions = fopts
            end,
            10
        )
    else
        vim.api.nvim_err_writeln "Unexpected mode"
    end
end

function M.move_windows()
    local view = require "utils.view"
    view.reposition_windows({ action = "move" })
end

function M.swap_windows()
    local view = require "utils.view"
    view.reposition_windows({ action = "swap" })
end

function M.reset_layout()
    vim.cmd "NoNeckPain"
    vim.cmd "NoNeckPain"
end

function M.change_window_width(direction)
    local view = require "utils.view"
    local sidenotes_visible = view.are_sidenotes_visible()

    if direction == "up" then
        if sidenotes_visible then
            vim.cmd "NoNeckPainWidthUp"
        else
            vim.cmd "vertical resize +5"
        end
    elseif direction == "down" then
        if sidenotes_visible then
            vim.cmd "NoNeckPainWidthDown"
        else
            vim.cmd "vertical resize -5"
        end
    else
        vim.api.nvim_err_writeln "Unexpected direction"
    end
end

function M.restore_windows_layout()
    local nnp = require "plugins.no-neck-pain"
    local view = require "utils.view"

    local sidenotes_visible = view.are_sidenotes_visible()

    if sidenotes_visible then
        vim.cmd("NoNeckPainResize " .. nnp.default_width)
    else
        vim.cmd "wincmd ="
    end
end

function M.scroll(direction)
    local view = require "utils.view"
    local keys = require "utils.keys"

    local current_win = vim.api.nvim_get_current_win()

    if view.is_window_floating(current_win) then
        local keymap

        if direction == "up" then
            keymap = "<C-u>"
        elseif direction == "down" then
            keymap = "<C-d>"
        else
            vim.api.nvim_err_writeln "Unexpected scroll direction"
            return
        end

        keys.send(keymap, { mode = "n" })
    else
        local lines = 5

        local keymap

        if direction == "up" then
            keymap = "<C-y>"
        elseif direction == "down" then
            keymap = "<C-e>"
        else
            vim.api.nvim_err_writeln "Unexpected scroll direction"
            return
        end

        local floating_windows = view.get_floating_tab_windows()

        if floating_windows and #floating_windows == 1 and floating_windows[1] ~= current_win then
            local win = floating_windows[1]
            vim.api.nvim_set_current_win(win)
            M.scroll(direction)
        else
            keys.send(tostring(lines) .. keymap, { mode = "n" })
        end
    end
end

function M.zenmode()
    local zenmode = require "utils.zenmode"
    zenmode.toggle()
end

function M.close_buffer(opts)
    local zenmode = require "utils.zenmode"

    if zenmode.is_active() then
        zenmode.deactivate()
        return
    end

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

    local search = require "utils.search"

    if search.is_active() then
        search.close()
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

    local filetree = require "utils.filetree"

    local current_buf = vim.api.nvim_get_current_buf()

    if filetree.is_tree(current_buf) then
        filetree.close()
        return
    end

    local view = require "utils.view"

    local current_win = vim.api.nvim_get_current_win()
    local floating_windows = view.get_floating_tab_windows()

    if floating_windows and #floating_windows == 1 and floating_windows[1] ~= current_win then
        -- Most likely LSP documentation floating window
        local floating_win = floating_windows[1]

        local cleanup = view.move_cursor_and_return()

        if not cleanup then
            vim.api.nvim_err_writeln "Failed to move cursor"
            return
        end

        vim.defer_fn(
            function()
                cleanup()

                local next_floating_windows = view.get_floating_tab_windows()

                if #next_floating_windows > 0 then
                    print("Floating window is not closed by cursor move. Trying to close it manually.")
                    vim.api.nvim_win_close(floating_win, false)
                end
            end,
            10
        )

        return
    end

    local buffers = require "utils.buffers"

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
        keys.send("<Esc>", { mode = "x" })
    end

    local tab_windows = view.get_tab_windows_with_listed_buffers({ incl_help = true })

    local should_close_window = opts.should_close_window

    if #tab_windows > 1 and should_close_window then
        vim.cmd "silent! write"

        for _, win in ipairs(tab_windows) do
            local buf = vim.api.nvim_win_get_buf(win)
            if buf == current_buf then
                vim.cmd.close()
                return
            end
        end
    else
        local bufs = buffers.get_listed_bufs({ sort_lastused = true })

        local next_buf = nil

        for _, buf in ipairs(bufs) do
            if buf.bufnr ~= current_buf then
                local opened_else_where = false

                for _, win in ipairs(tab_windows) do
                    local win_buf = vim.api.nvim_win_get_buf(win)
                    if win_buf == buf.bufnr then
                        opened_else_where = true
                        break
                    end
                end

                if not opened_else_where then
                    next_buf = buf.bufnr
                    break
                end
            end
        end

        if next_buf ~= nil then
            vim.cmd "silent! write"
            vim.api.nvim_set_current_buf(next_buf)
        else
            if #tab_windows > 1 then
                vim.cmd "silent! write"
                vim.cmd.close()
            else
                local empty_buf = vim.api.nvim_create_buf(true, false)

                if empty_buf == 0 then
                    vim.api.nvim_err_writeln "Failed to create empty buffer"
                    vim.cmd "silent! write"
                else
                    vim.cmd "silent! write"
                    vim.api.nvim_set_current_buf(empty_buf)
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

    if incl_unsaved then
        print "Closed all buffers except current"
    else
        print "Closed all buffers except current and unsaved"
    end
end

function M.quit()
    local git = require "utils.git"
    local term = require "utils.terminal"
    local zenmode = require "utils.zenmode"
    local filetree = require "utils.filetree"
    local search = require "utils.search"

    local mode = vim.fn.mode()

    if mode == "i" or mode == "v" then
        local keys = require "utils.keys"
        keys.send("<Esc>", { mode = "x" })
    end

    git.ensure_diff_hidden()
    term.ensure_hidden()
    filetree.ensure_hidden()
    zenmode.ensure_deacitvated()
    search.ensure_closed()

    -- NOTE: Not `wqa` due to toggleterm issue
    vim.cmd "wa"
    vim.cmd "qa"
end

return M
