local set = function(m, k, a, o)
    local opts = { noremap = true, silent = true }

    if o ~= nil then
        opts = vim.tbl_extend("force", opts, o)
    end

    vim.keymap.set(m, k, a, opts)
end

-- undo/redo
set("i", "<C-u>", "<Esc>ui")
set("i", "<C-r>", "<Esc><C-r>i")

-- select all
set("n", "<C-a>", "ggVG")
set({ "i", "v" }, "<C-a>", "<Esc>ggVG")

-- duplicate line
set("n", "<M-d>", "yyp")
set("v", "<M-d>", "y'>p")
set("i", "<M-d>", "<Esc>yyp")

-- insert new line
set("n", "<M-j>", "o<Esc>")
set("n", "<M-k>", "O<Esc>")
set("i", "<M-j>", "<Esc>o")
set("i", "<M-k>", "<Esc>O")

-- Move lines
set("n", "<M-Up>", "<Cmd>m .-2<CR>==")
set("n", "<M-Down>", "<Cmd>m .+1<CR>==")
set("i", "<M-Up>", "<Esc><Cmd>m .-2<CR>==gi")
set("i", "<M-Down>", "<Esc><Cmd>m .+1<CR>==gi")
set("v", "<M-Up>", "<Cmd>m '<-2<CR>gv=gv")
set("v", "<M-Down>", "<Cmd>m '>+1<CR>gv=gv")

-- indent
set("n", "<Tab>", ">>")
set("n", "<M-Tab>", "<<")
set("v", "<Tab>", ">gv")
set("v", "<M-Tab>", "<gv")

-- navigate within buffer
set("", "<C-h>", "<Cmd>HopWord<CR>")
set("n", "<C-k>", "<C-u>")
set("n", "<C-j>", "<C-d>")

-- navigate between splits
set({ "n", "t" }, "<C-Left>", "<Cmd>wincmd h<CR>") -- left
set({ "n", "t" }, "<C-Down>", "<Cmd>wincmd j<CR>") -- down
set({ "n", "t" }, "<C-Up>", "<Cmd>wincmd k<CR>") -- up
set({ "n", "t" }, "<C-Right>", "<Cmd>wincmd l<CR>") -- right

-- navigate history
set("n", "<Leader>m", "<C-o>")
set("n", "<Leader>,", "<C-i>")
set("n", "<LeftMouse>", "m'<LeftMouse>")

-- save file
set("n", "<C-s>", "<Cmd>w<CR>")
set({ "i", "v" }, "<C-s>", "<Esc><Cmd>w<CR>")

-- don't jump on *
set("n", "*", "<Cmd>keepjumps normal! mi*`i<CR>")

-- drop search highlight and clear the command line (I hope I don't do stupid things here :pray:)
set("n", "<Esc>", "<Cmd>silent noh<CR>:<BS>", { silent = false })

-- zen mode
set(
    "",
    "<C-z>",
    function()
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
)

-- close pane
set(
    { "n", "i", "v" },
    "<C-w>",
    function()
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
)

-- close all buffers except the current and unsaved ones
set(
    { "n", "i", "v" },
    "<M-w>",
    function()
        local filetree = require "utils/filetree"

        local current_buf = vim.api.nvim_get_current_buf()
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })

        vim.cmd "silent! wa"

        for _, buf in ipairs(bufs) do
            local unnamed_modified = buf.name == "" and buf.changed == 1
            if buf.bufnr ~= current_buf and not unnamed_modified and not filetree.is_tree(buf.bufnr) then
                vim.cmd.bdelete(buf.bufnr)
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
)

-- quit
set(
    { "n", "i", "v", "t" },
    "<C-q>",
    function()
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
)

-- lsp
set("n", "<C-d>", "<Cmd>TroubleToggle<CR>")
set("n", "<Leader>g", "<Cmd>Lspsaga goto_definition<CR>")
set("n", "<Leader>r", "<Cmd>Lspsaga rename<CR>")
set("n", "<Leader>o", "<Cmd>Lspsaga outline<CR>")
set("n", "<Leader>a", "<Cmd>Lspsaga code_action<CR>")
set("n", "<Leader>h", "<Cmd>Lspsaga hover_doc<CR>")
set("n", "<Leader>f", "<Cmd>Lspsaga lsp_finder<CR>")
set("n", "<Leader>dj", "<Cmd>Lspsaga diagnostic_jump_next<CR>")
set("n", "<Leader>dk", "<Cmd>Lspsaga diagnostic_jump_prev<CR>")

-- comments (also, see plugins/comment.lua)
set("i", "<C-c>", "<Esc><Cmd>normal <C-c><CR>gi")

-- file tree
-- NOTE: Requires disabling of the default keymap edit_in_place
set({ "n", "v" }, "<C-e>", "<Cmd>NvimTreeToggle<CR>")
set("n", "<Leader>/", "<Cmd>NvimTreeFindFile<CR>")

-- telescope
local telescope = {
    builtin = require("telescope.builtin"),
    extensions = require("telescope").extensions,
}

set(
    "n",
    "<C-p>",
    function()
        telescope.builtin.commands({
            initial_mode = "insert",
        })
    end

)

set(
    "n",
    "<C-f>f",
    function()
        telescope.builtin.find_files({
            hidden = true,
            no_ignore = false,
            initial_mode = "insert",
        })
    end
)

set(
    "n",
    "<C-f>t",
    function()
        telescope.builtin.live_grep({
            hidden = true,
            no_ignore = false,
            initial_mode = "insert",
        })
    end
)

set(
    { "n", "t" }, -- FIXME: "t" needs proper cwd
    "<C-o>",
    function()
        telescope.extensions.file_browser.file_browser({
            cwd = "%:p:h",
            hidden = true,
            respect_gitignore = false,
            grouped = true,
            select_buffer = true,
            initial_mode = "normal",
        })
    end
)

set(
    "n",
    "<C-b>",
    function()
        telescope.builtin.buffers({
            initial_mode = "normal",
        })
    end
)

-- terminal
set({ "n", "t" }, "<C-t>", "<Cmd>ToggleTerm<CR>")

-- git
local lazygit = require "plugins/lazygit"

set("n", "<C-g>", lazygit.toggle)
set("n", "<M-g>", "<Cmd>Gitsigns stage_buffer<CR>")

-- statusline
set(
    { "n", "i", "v" },
    "<C-l>",
    function()
        local plugin = require "lualine"
        local config = plugin.get_config()
        for _, section in pairs(config.sections) do
            for _, component in ipairs(section) do
                if type(component) == "table" and component[1] == "filename" then
                    if component.path == 0 then
                        component.path = 1
                    else
                        component.path = 0
                    end
                end
            end

        end
        plugin.setup(config)
    end
)
