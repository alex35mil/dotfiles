local editor = require "mappings.editor"
local git = require "mappings.git"
local lsp = require "mappings.lsp"
local filetree = require "mappings.filetree"
local telescope = require "mappings.telescope"
local statusline = require "mappings.statusline"
local terminal = require "mappings.terminal"
local search = require "mappings.search"

local function map(mappings)
    local wk = require "which-key"

    for k, m in pairs(mappings) do
        local cmd = m[2]
        local desc = m[1]

        table.remove(m, 1)
        table.remove(m, 2)

        m[1] = cmd
        m[2] = desc

        mappings[k] = m
    end

    wk.register(mappings, { noremap = true, silent = true })
end

-- NB!: `which-key` freaks out when `mode = ""`
-- NB!: Sometimes, when arg of `map` has multiple keys, one or more keys don't apply

map { ["<D-c>"] = { "Copy selected text", [["+y]], mode = "v" } }
map { ["<D-v>"] = { "Paste text", [["+P]], mode = { "v" } } }
map { ["<D-v>"] = { "Paste text", "<C-r>+", mode = { "i", "c" } } }
map { ["<D-v>"] = { "Paste text", terminal.paste, mode = "t", expr = true } }

map { ["<D-v>"] = { "Start visual selection", "<C-v>", mode = "n" } }

map {
    ["p"] = {
        "Don't replace clipboard content when pasting",
        function() return 'pgv"' .. vim.v.register .. "ygv" end,
        mode = "v",
        expr = true,
    },
}
map { ["d"] = { "Don't replace clipboard content when deleting", [["_d]], mode = { "n", "v" } } }
map { ["s"] = { "Don't replace clipboard content when inserting", [["xs]], mode = "v" } }
map { ["c"] = { "Don't replace clipboard content when changing", [["xc]], mode = { "n", "v" } } }

map { ["<CR>"] = { "Change inner word", [["xciw]], mode = "n" } }
map { ["<C-c>"] = { "Change inner word", [["xciw]], mode = "n" } }
map { ["<M-CR>"] = { "Select inner word", "viw", mode = "n" } }
map { ["<D-CR>"] = { "Yank inner word", "yiw", mode = "n" } }

map { ["<C-t>"] = { "Insert new line above", "O<Esc>", mode = "n" } }
map { ["<C-h>"] = { "Insert new line below", "o<Esc>", mode = "n" } }
map { ["<C-t>"] = { "Insert new line above", "<Esc>O", mode = "i" } }
map { ["<C-h>"] = { "Insert new line below", "<Esc>o", mode = "i" } }

map { ["<C-d>"] = { "Duplicate line", [["yyy"yp]], mode = "n" } }
map { ["<C-d>"] = { "Duplicate line", [[<Esc>"yyy"ypgi]], mode = "i" } }
map { ["<C-d>"] = { "Duplicate selection", [["yy'>"ypgv]], mode = "v" } }

map { ["<M-Up>"] = { "Move line up", "<Cmd>m .-2<CR>==", mode = "n" } }
map { ["<M-Down>"] = { "Move line down", "<Cmd>m .+1<CR>==", mode = "n" } }
map { ["<M-Up>"] = { "Move line up", "<Esc><Cmd>m .-2<CR>==gi", mode = "i" } }
map { ["<M-Down>"] = { "Move line down", "<Esc><Cmd>m .+1<CR>==gi", mode = "i" } }
map { ["<M-Up>"] = { "Move selected lines up", "<Cmd>m '<-2<CR>gv=gv", mode = "v" } }
map { ["<M-Down>"] = { "Move selected lines down", "<Cmd>m '>+1<CR>gv=gv", mode = "v" } }

map { ["<Tab>"] = { "Indent", ">>", mode = "n" } }
map { ["<S-Tab>"] = { "Unindent", "<<", mode = "n" } }
map { ["<Tab>"] = { "Indent", ">gv", mode = "v" } }
map { ["<S-Tab>"] = { "Unindent", "<gv", mode = "v" } }

map { ["<D-a>"] = { "Select all", "ggVG", mode = "n" } }
map { ["<D-a>"] = { "Select all", "<Esc>ggVG", mode = { "i", "v" } } }

map { ["<D-t>"] = { "Move cursor half-screen up", "<C-u>", mode = { "n", "v" } } }
map { ["<M-h>"] = { "Move cursor half-screen down", "<C-d>", mode = { "n", "v" } } } -- It is <D-h> remapped via Karabiner

map { ["<D-d>"] = { "History: back", "<C-o>", mode = "n" } }
map { ["<D-n>"] = { "History: forward", "<C-i>", mode = "n" } }
map { ["<LeftMouse>"] = { "History: include mouse clicks", "m'<LeftMouse>", mode = "n" } }

map { ["s"] = { "Start pounce motion", "<Cmd>Pounce<CR>", mode = "n" } }
map { ["S"] = { "Start pounce motion", "<Cmd>Pounce<CR>", mode = "v" } }

map { ["*"] = { "Don't jump on *", "<Cmd>keepjumps normal! mi*`i<CR>", mode = { "n", "v" } } }
map { ["<Esc>"] = { "Drop search highlight and clear the command line", "<Cmd>silent noh<CR>:<BS>", mode = "n", silent = false } }

map { ["<D-u>"] = { "Undo", "<Esc>ui", mode = "i" } }
map { ["<C-u>"] = { "Redo", "<Esc><C-r>i", mode = "i" } }
map { ["<C-u>"] = { "Redo", "<C-r>", mode = { "n", "v" } } }

map { ["<D-/>"] = { "Toggle comments", "<Plug>(comment_toggle_linewise_current)", mode = "n" } }
map { ["<D-/>"] = { "Toggle comments", "<Plug>(comment_toggle_linewise_visual)", mode = "v" } }
map { ["<D-/>"] = { "Toggle comments", "<Esc><Plug>(comment_toggle_linewise_current)gi", mode = "i" } }

map { ["<D-s>"] = { "Save current file", "<Cmd>silent w<CR>", mode = "n" } }
map { ["<D-s>"] = { "Save current file", "<Esc><Cmd>silent w<CR>", mode = { "i", "v" } } }
map { ["<D-M-s>"] = { "Save all files", "<Cmd>silent! wa<CR>", mode = "n" } }
map { ["<D-M-s>"] = { "Save all files", "<Esc><Cmd>silent! wa<CR>", mode = { "i", "v" } } }

map { ["<D-Left>"] = { "Move to window on the left", "<Cmd>wincmd h<CR>", mode = { "n", "t" } } }
map { ["<D-Down>"] = { "Move to window below", "<Cmd>wincmd j<CR>", mode = { "n", "t" } } }
map { ["<D-Up>"] = { "Move to window above", "<Cmd>wincmd k<CR>", mode = { "n", "t" } } }
map { ["<D-Right>"] = { "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "t" } } }

map { ["<D-z>"] = { "Toggle zen mode", editor.zenmode, mode = { "n", "i", "v" } } }

map { ["<C-n>c"] = { "Open new buffer in the current window", "<Cmd>enew<CR>", mode = "n" } }
map { ["<C-n>h"] = { "Open new horizontal split", "<Cmd>new<CR>", mode = "n" } }
map { ["<C-n>n"] = { "Open new vertical split", "<Cmd>vnew<CR>", mode = "n" } }

map {
    ["<D-w>"] = {
        "Close current buffer and close current window if there are multiple",
        function() editor.close_buffer({ should_close_window = true }) end,
        mode = { "n", "i", "v", "t" },
    },
}
map {
    ["<M-w>"] = {
        "Close current buffer, but do not close current window when there are multiple",
        function() editor.close_buffer({ should_close_window = false }) end,
        mode = { "n", "i", "v" },
    },
}
map {
    ["<Leader>ww"] = {
        "Close all buffers except current & unsaved",
        function() editor.close_all_bufs_except_current({ incl_unsaved = false }) end,
        mode = "n",
    },
}
map {
    ["<Leader>wa"] = {
        "Close all buffers except current",
        function() editor.close_all_bufs_except_current({ incl_unsaved = true }) end,
        mode = "n",
    },
}
map { ["<C-q>"] = { "Quit editor", editor.quit, mode = { "n", "i", "v", "t" } } }                       -- It is <D-q> remapped via Karabiner

map { ["<D-o>"] = { "Open file browser", telescope.open_file_browser, mode = { "n", "i", "v", "t" } } } -- FIXME: "t" needs proper cwd
map { ["<D-b>"] = { "Open buffer selector", telescope.buffer, mode = { "n", "i", "v" } } }
map { ["<D-f>f"] = { "Open file finder", telescope.find_file, mode = { "n", "i", "v" } } }
map { ["<D-f>t"] = { "Open project-wide text search", telescope.find_text, mode = { "n", "i", "v" } } }

map { ["<Leader>tc"] = { "Find command", telescope.command, mode = "n" } }
map { ["<Leader>th"] = { "Open highlights list", "<Cmd>Telescope highlights<CR>", mode = "n" } }

map {
    ["<Leader>tta"] = {
        "Find all TODO comments",
        function() telescope.todos({ todo = true, fixme = true }) end,
        mode = "n",
    },
}
map {
    ["<Leader>ttt"] = {
        "Find TODOs",
        function() telescope.todos({ todo = true }) end,
        mode = "n",
    },
}
map {
    ["<Leader>ttf"] = {
        "Find FIXMEs",
        function() telescope.todos({ fixme = true }) end,
        mode = "n",
    },
}

map { ["<Leader>sg"] = { "Open project search", search.open, mode = "n" } }
map { ["<Leader>sc"] = { "Open search in current buffer", search.current_buffer, mode = "n" } }
map { ["<Leader>swg"] = { "Search current word in project", search.word, mode = "n" } }
map { ["<Leader>swc"] = { "Search current word in current buffer", search.word_in_current_buffer, mode = "n" } }

map { ["<M-d>l"] = { "Toggle LSP diagnostic lines", lsp.toggle_lines, mode = "n" } }
map {
    ["<M-d>a"] = {
        "List all LSP diagnostics for the whole workspace",
        function() telescope.diagnostics({ current_buffer = false }) end,
        mode = { "n", "i", "v" },
    },
}
map {
    ["<M-d>e"] = {
        "List LSP diagnostics with ERROR severity for the whole workspace",
        function() telescope.diagnostics({ min_severity = "ERROR", current_buffer = false }) end,
        mode = { "n", "i", "v" },
    },
}
map {
    ["<M-d>w"] = {
        "List LSP diagnostics with WARN & ERROR severities for the whole workspace",
        function() telescope.diagnostics({ min_severity = "WARN", current_buffer = false }) end,
        mode = { "n", "i", "v" },
    },
}

map {
    ["<M-d>ca"] = {
        "List all LSP diagnostics for the current buffer only",
        function() telescope.diagnostics({ current_buffer = true }) end,
        mode = { "n", "i", "v" },
    },
}
map {
    ["<M-d>ce"] = {
        "List LSP diagnostics with ERROR severity for the current buffer only",
        function() telescope.diagnostics({ min_severity = "ERROR", current_buffer = true }) end,
        mode = { "n", "i", "v" },
    },
}
map {
    ["<M-d>cw"] = {
        "List LSP diagnostics with WARN & ERROR severities for the current buffer only",
        function() telescope.diagnostics({ min_severity = "WARN", current_buffer = true }) end,
        mode = { "n", "i", "v" },
    },
}

map { ["<D-p>p"] = { "Open plugins manager", "<Cmd>Lazy<CR>", mode = "n" } }
map { ["<D-p>l"] = { "Open package manager", "<Cmd>Mason<CR>", mode = "n" } }

map { ["<D-e>"] = { "Toggle file tree", filetree.toggle, mode = { "n", "i", "v" } } }

map { ["<M-t>t"] = { "Toggle tab terminal", terminal.toggle_tab, mode = { "n", "i", "v", "t" } } }
map { ["<M-t>f"] = { "Toggle float terminal", terminal.toggle_float, mode = { "n", "i", "v", "t" } } }
map { ["<M-t>h"] = { "Toggle horizontal terminal", terminal.toggle_horizontal, mode = { "n", "i", "v", "t" } } }
map { ["<C-n>"] = { "Exit terminal mode", "<C-\\><C-n>", mode = "t" } }

map { ["<D-g>g"] = { "Git: Show lazygit", "<Cmd>LazyGit<CR>", mode = "n" } }
map { ["<D-g>d"] = { "Git: Toggle diff", git.toggle_diff, mode = "n" } }
map { ["<D-g>j"] = { "Git: Jump to the next hunk", "<Cmd>Gitsigns next_hunk<CR>", mode = "n" } }
map { ["<D-g>k"] = { "Git: Jump to the previous hunk", "<Cmd>Gitsigns prev_hunk<CR>", mode = "n" } }
map { ["<D-g>b"] = { "Git: Show line blame", "<Cmd>Gitsigns blame_line<CR>", mode = "n" } }
map { ["<C-Space>"] = { "Git: Stage hunk", "<Cmd>Gitsigns stage_hunk<CR>", mode = "n" } }
map { ["<C-S-Space>"] = { "Git: Unstage hunk", "<Cmd>Gitsigns undo_stage_hunk<CR>", mode = "n" } }

map { ["<M-l>"] = { "Toggle filename in statusline", statusline.toggle_filename, mode = { "n", "i", "v" } } }

map { ["<D-C-h>"] = { "LSP: Jump to definition", "<Cmd>Lspsaga goto_definition<CR>", mode = "n" } }
map { ["<C-r>"] = { "LSP: Rename", "<Cmd>Lspsaga rename<CR>", mode = "n" } }
map { ["<C-o>"] = { "LSP: Outline", "<Cmd>Lspsaga outline<CR>", mode = "n" } }
map { ["<C-a>"] = { "LSP: Code actions", "<Cmd>Lspsaga code_action<CR>", mode = "n" } }
map { ["<C-i>"] = { "LSP: Hint", "<Cmd>Lspsaga hover_doc<CR>", mode = "n" } }
map { ["<C-f>"] = { "LSP: Finder", "<Cmd>Lspsaga lsp_finder<CR>", mode = "n" } }
map { ["<C-s>"] = { "LSP: Doc", vim.lsp.buf.hover, mode = "n" } }
map { ["}"] = { "LSP: Diagnostic next error", lsp.jump_to_next_error, mode = "n" } }
map { ["{"] = { "LSP: Diagnostic previous error", lsp.jump_to_prev_error, mode = "n" } }
map { ["<C-}>"] = { "LSP: Diagnostic next warning", lsp.jump_to_next_warning, mode = "n" } }
map { ["<C-{>"] = { "LSP: Diagnostic previous warning", lsp.jump_to_prev_warning, mode = "n" } }
