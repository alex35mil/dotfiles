local M = {}
local m = {}

function M.keymaps()
    K.map {
        "<D-w>",
        "Delete current buffer, but do not close current window if there are multiple",
        function() m.delete_buf({ should_close_window = false, force = false }) end,
        mode = { "n", "v" },
    }
    K.map {
        "<C-w>",
        "Delete current buffer and close current window if there are multiple",
        function() m.delete_buf({ should_close_window = true, force = false }) end,
        mode = { "n", "i", "v", "t", "c" },
    }
    K.mapseq {
        "<Leader>wck",
        "Delete current buffer, even if unsaved, but do not close current window if there are multiple",
        function() m.delete_buf({ should_close_window = false, force = true }) end,
        mode = { "n", "v" },
    }
    K.map {
        "<Leader>wcc",
        "Delete current buffer, even if unsaved, and close current window if there are multiple",
        function() m.delete_buf({ should_close_window = true, force = true }) end,
        mode = { "n", "i", "v" },
    }
    K.mapseq {
        "<Leader>was",
        "Delete all buffers except current & unsaved",
        function() m.delete_all_bufs_except_current({ incl_unsaved = false }) end,
        mode = "n",
    }
    K.mapseq {
        "<Leader>waf",
        "Delete all buffers except current",
        function() m.delete_all_bufs_except_current({ incl_unsaved = true }) end,
        mode = "n",
    }
end

function M.is_buf_listed(bufnr)
    local buf = m.get_buf_info(bufnr)
    return buf.listed == 1
end

function M.get_listed_bufs(opts)
    local o = opts or {}
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })

    if o.sort_lastused then
        table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
    end

    return bufs
end

-- Private

function m.get_buf_info(bufnr)
    return vim.fn.getbufinfo(bufnr)[1]
end

function m.delete_buf(options)
    local noice = require "plugins.noice"
    if noice.ensure_hidden() then
        return
    end

    local alpha = require "plugins.alpha"
    if alpha.is_active() then
        return
    end

    local zenmode = require "plugins.zen-mode"
    if zenmode.ensure_deacitvated() then
        return
    end

    local lazygit = require "plugins.git.lazygit"
    if lazygit.ensure_hidden() then
        return
    end

    local diffview = require "plugins.git.diffview"
    if diffview.ensure_current_hidden() then
        return
    end

    local spectre = require "plugins.spectre"
    if spectre.ensure_active_closed() then
        return
    end

    local lazy = require "plugins.lazy"
    if lazy.ensure_hidden() then
        return
    end

    local mason = require "plugins.lsp.mason"
    if mason.ensure_hidden() then
        return
    end

    local term = require "plugins.toggleterm"
    if term.ensure_active_hidden() then
        return
    end

    local filetree = require "plugins.neo-tree"
    if filetree.ensure_active_hidden() then
        return
    end

    local windows = require "editor.windows"

    local current_win = vim.api.nvim_get_current_win()

    local opts = vim.tbl_extend("keep", options, { force = false, should_close_window = false })

    local current_buf = vim.api.nvim_get_current_buf()
    local current_buf_info = m.get_buf_info(current_buf)

    if current_buf_info == nil then
        vim.api.nvim_err_writeln "Can't get current buffer info"
        return
    end

    if current_buf_info.name == "" and current_buf_info.changed == 1 and not opts.force then
        vim.api.nvim_err_writeln "The buffer needs to be saved first"
        return
    end

    local mode = vim.fn.mode()

    if mode ~= "n" then
        local keys = require "editor.keys"
        keys.send("<Esc>", { mode = "x" })
    end

    local tab_windows = windows.get_tab_windows_with_listed_buffers({ incl_help = true })

    if tab_windows == nil then
        vim.api.nvim_err_writeln "No windows in the current tab"
        return
    end

    local is_opened_elsewhere = false

    if #tab_windows > 1 then
        is_opened_elsewhere = m.is_opened_elsewhere(tab_windows, current_win, current_buf)
    end

    if #tab_windows > 1 and opts.should_close_window then
        vim.cmd "silent! write"
        vim.cmd.close()

        -- We don't want to destroy the buffer that is shown in another window
        if not is_opened_elsewhere then
            vim.api.nvim_buf_delete(current_buf, { force = opts.force })
        end
    else
        local bufs = M.get_listed_bufs({ sort_lastused = true })

        -- Searching for the next buffer to show in the current window
        local next_buf = nil

        for _, buf in ipairs(bufs) do
            if buf.bufnr ~= current_buf then
                -- If there are multiple windows opened, we don't want to show the buffer
                -- that is already opened in another window. So if it's the case,
                -- we skip it and continue searching for the next buffer.
                local opened_else_where = false

                for _, win in ipairs(tab_windows) do
                    local win_buf = vim.api.nvim_win_get_buf(win)
                    if win_buf == buf.bufnr then
                        opened_else_where = true
                        break
                    end
                end

                if not opened_else_where then
                    -- that's the one
                    next_buf = buf.bufnr
                    break
                end
            end
        end

        if next_buf ~= nil then
            vim.cmd "silent! write"
            vim.api.nvim_set_current_buf(next_buf)
            if not is_opened_elsewhere then
                vim.api.nvim_buf_delete(current_buf, { force = opts.force })
            end
        else
            if #tab_windows > 1 then
                vim.cmd "silent! write"
                vim.cmd.close()
                if not is_opened_elsewhere then
                    vim.api.nvim_buf_delete(current_buf, { force = opts.force })
                end
            else
                local empty_buf = vim.api.nvim_create_buf(true, false)

                if empty_buf == 0 then
                    vim.api.nvim_err_writeln "Failed to create empty buffer"
                    vim.cmd "silent! write"
                else
                    vim.cmd "silent! write"
                    vim.api.nvim_set_current_buf(empty_buf)
                end

                vim.api.nvim_buf_delete(current_buf, { force = opts.force })
            end
        end
    end
end

function m.delete_all_bufs_except_current(opts)
    local filetree = require "plugins.neo-tree"

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

    local windows = require "editor.windows"

    local current_win = vim.api.nvim_get_current_win()
    local windows_with_listed_buffers = windows.get_tab_windows_with_listed_buffers()

    if windows_with_listed_buffers == nil then
        print "No windows with listed buffers"
        return
    end

    for _, win in ipairs(windows_with_listed_buffers) do
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

function m.is_opened_elsewhere(tab_wins, current_win, current_buf)
    for _, win in ipairs(tab_wins) do
        if win ~= current_win then
            local win_buf = vim.api.nvim_win_get_buf(win)
            if current_buf == win_buf then
                return true
            end
        end
    end

    return false
end

return M
