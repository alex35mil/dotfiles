local editor = require "actions.editor"
local git = require "actions.git"
local lsp = require "actions.lsp"
local telescope = require "actions.telescope"
local filetree = require "actions.filetree"
local statusline = require "actions.statusline"
local terminal = require "actions.terminal"
local search = require "actions.search"

local default_options = { noremap = true, silent = true }

local function map(mapping)
    -- NB!: it is important to remove items in reverse order to avoid shifting
    local cmd = table.remove(mapping, 3)
    local desc = table.remove(mapping, 2)
    local key = table.remove(mapping, 1)

    local mode = mapping["mode"]

    mapping["mode"] = nil
    mapping["desc"] = desc

    local options = vim.tbl_extend("force", default_options, mapping)

    vim.keymap.set(mode, key, cmd, options)
end

local function mapseq(mapping)
    local wk = require "which-key"

    local keymap = {}

    -- NB!: it is important to remove items in reverse order to avoid shifting
    local cmd = table.remove(mapping, 3)
    local desc = table.remove(mapping, 2)
    local key = table.remove(mapping, 1)

    mapping[1] = cmd
    mapping[2] = desc

    keymap[key] = mapping

    wk.register(keymap, default_options)
end

map { "<D-c>", "Copy selected text", [["+y]], mode = "v" }
map { "<D-v>", "Paste text", [["+P]], mode = "v" }
map { "<D-v>", "Paste text", "<C-r>+", mode = { "i", "c" } }
map { "<D-v>", "Paste text", terminal.paste, mode = "t", expr = true }

map { "<D-v>", "Start visual selection", "<C-v>", mode = "n" }

map {
    "p",
    "Don't replace clipboard content when pasting",
    function() return 'pgv"' .. vim.v.register .. "ygv" end,
    mode = "v",
    expr = true,

}
map { "d", "Don't replace clipboard content when deleting", [["_d]], mode = { "n", "v" } }
map { "s", "Don't replace clipboard content when inserting", [["xs]], mode = "v" }
map { "c", "Don't replace clipboard content when changing", [["xc]], mode = { "n", "v" } }

map { "<CR>", "Change inner word", [["xciw]], mode = "n" }
map { "<CR>", "Change seletion", [["xc]], mode = "v" }
map { "<D-CR>", "Select inner word", "viw", mode = "n" }
map { "<C-c>", "Change inner word", [["xciw]], mode = "n" }
map { "<C-y>", "Yank inner word", "yiw", mode = "n" }

map { "<C-t>", "Insert new line above", "O<Esc>", mode = "n" }
map { "<C-h>", "Insert new line below", "o<Esc>", mode = "n" }
map { "<C-t>", "Insert new line above", "<Esc>O", mode = "i" }
map { "<C-h>", "Insert new line below", "<Esc>o", mode = "i" }
map { "<D-CR>", "Insert new line below", "<Esc>o", mode = "i" }

map { "<C-d>", "Duplicate line", [["yyy"yp]], mode = "n" }
map { "<C-d>", "Duplicate line", [[<Esc>"yyy"ypgi]], mode = "i" }
map { "<C-d>", "Duplicate selection", [["yy'>"ypgv]], mode = "v" }

map { "<M-Up>", "Move line up", "<Cmd>m .-2<CR>==", mode = "n" }
map { "<M-Down>", "Move line down", "<Cmd>m .+1<CR>==", mode = "n" }
map { "<M-Up>", "Move line up", "<Esc><Cmd>m .-2<CR>==gi", mode = "i" }
map { "<M-Down>", "Move line down", "<Esc><Cmd>m .+1<CR>==gi", mode = "i" }
map { "<M-Up>", "Move selected lines up", ":m '<-2<CR>gv=gv", mode = "v" }
map { "<M-Down>", "Move selected lines down", ":m '>+1<CR>gv=gv", mode = "v" }

map { "<Tab>", "Indent", ">>", mode = "n" }
map { "<S-Tab>", "Unindent", "<<", mode = "n" }
map { "<Tab>", "Indent", ">gv", mode = "v" }
map { "<S-Tab>", "Unindent", "<gv", mode = "v" }

map { "<D-a>", "Select all", "ggVG", mode = "n" }
map { "<D-a>", "Select all", "<Esc>ggVG", mode = { "i", "v" } }

map { "T", "Move cursor half-screen up", "<C-u>", mode = { "n", "v" } }
map { "H", "Move cursor half-screen down", "<C-d>", mode = { "n", "v" } }

map { "<S-Up>", "Scroll up", "5<C-y>", mode = { "n", "v", "i" } }
map { "<S-Down>", "Scroll down", "5<C-e>", mode = { "n", "v", "i" } }

map { "<D-d>", "History: back", "<C-o>", mode = "n" }
map { "<D-n>", "History: forward", "<C-i>", mode = "n" }
map { "<LeftMouse>", "History: include mouse clicks", "m'<LeftMouse>", mode = "n" }

map { "<M-h>", "Start pounce motion", "<Cmd>Pounce<CR>", mode = { "n", "v" } } -- It's <D-h> remapped via Karabiner

map { "*", "Don't jump on *", "<Cmd>keepjumps normal! mi*`i<CR>", mode = "n" }
map {
    "*",
    "Highlight selected text",
    [["*y:silent! let searchTerm = '\V'.substitute(escape(@*, '\/'), "\n", '\\n', "g") <bar> let @/ = searchTerm <bar> echo '/'.@/ <bar> call histadd("search", searchTerm) <bar> set hls<cr>]],
    mode = "v",
}
map { "<Esc>", "Drop search highlight and clear the command line", "<Cmd>silent noh<CR>:<BS>", mode = "n", silent = false }

map { "<C-u>", "Undo", "u", mode = { "n", "v" } }
map { "<C-u>", "Undo", "<Esc>ui", mode = "i" }
map { "<C-r>", "Redo", "<Esc><C-r>i", mode = "i" }

map { "<D-/>", "Toggle comments", "<Plug>(comment_toggle_linewise_current)", mode = "n" }
map { "<D-/>", "Toggle comments", "<Plug>(comment_toggle_linewise_visual)", mode = "v" }
map { "<D-/>", "Toggle comments", "<Esc><Plug>(comment_toggle_linewise_current)gi", mode = "i" }

map { "<D-s>", "Save all files", "<Cmd>silent w<CR><Cmd>silent! wa<CR>", mode = "n" }
map { "<D-s>", "Save all files", "<Esc><Cmd>silent w<CR><Cmd>silent! wa<CR>", mode = { "i", "v" } }
map { "<C-s>", "Save current file", "<Cmd>silent w<CR>", mode = "n" }
map { "<C-s>", "Save current file", "<Esc><Cmd>silent w<CR>", mode = { "i", "v" } }

map { "<D-Left>", "Move to window on the left", "<Cmd>wincmd h<CR>", mode = { "n", "t" } }
map { "<D-Down>", "Move to window below", "<Cmd>wincmd j<CR>", mode = { "n", "t" } }
map { "<D-Up>", "Move to window above", "<Cmd>wincmd k<CR>", mode = { "n", "t" } }
map { "<D-Right>", "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "t" } }

map { "<C-Up>", "Increase window width", function() editor.change_window_width("up") end, mode = "n" }
map { "<C-Down>", "Decrease window width", function() editor.change_window_width("down") end, mode = "n" }
map { "<C-Esc>", "Restore window width", editor.restore_windows_layout, mode = "n" }

map { "<C-M-Right>", "Rotate windows", editor.rotate_windows, mode = "n" }

map { "<D-z>", "Toggle zen mode", editor.zenmode, mode = { "n", "i", "v" } }

map { "<C-n>", "Open new buffer in the current window", "<Cmd>enew<CR>", mode = "n" }
mapseq { "<Leader>nh", "Open new horizontal split", "<Cmd>new<CR>", mode = "n" }
mapseq { "<Leader>nv", "Open new vertical split", "<Cmd>vnew<CR>", mode = "n" }

map {
    "<D-w>",
    "Close current buffer and close current window if there are multiple",
    function() editor.close_buffer({ should_close_window = true }) end,
    mode = { "n", "i", "v", "t" },
}
map {
    "<C-w>",
    "Close current buffer, but do not close current window when there are multiple",
    function() editor.close_buffer({ should_close_window = false }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>wo",
    "Close all buffers except current & unsaved",
    function() editor.close_all_bufs_except_current({ incl_unsaved = false }) end,
    mode = "n",
}
mapseq {
    "<Leader>wf",
    "Close all buffers except current",
    function() editor.close_all_bufs_except_current({ incl_unsaved = true }) end,
    mode = "n",
}

map { "<C-q>", "Quit editor", editor.quit, mode = { "n", "i", "v", "t" } } -- It's <D-q> remapped via Karabiner

map { "<D-b>", "Open buffer selector", telescope.buffer, mode = { "n", "i", "v" } }
map { "<D-t>", "Open file finder", telescope.find_file, mode = { "n", "i", "v" } }
map { "<D-f>", "Open project-wide text search", telescope.find_text, mode = { "n", "i", "v" } }

mapseq { "<Leader>tc", "Find command", telescope.command, mode = "n" }
mapseq { "<Leader>th", "Open highlights list", "<Cmd>Telescope highlights<CR>", mode = "n" }

mapseq {
    "<Leader>tta",
    "Find all TODO comments",
    function() telescope.todos({ todo = true, fixme = true }) end,
    mode = "n",
}
mapseq {
    "<Leader>ttt",
    "Find all TODOs",
    function() telescope.todos({ todo = true }) end,
    mode = "n",
}
mapseq {
    "<Leader>ttf",
    "Find all FIXMEs",
    function() telescope.todos({ fixme = true }) end,
    mode = "n",
}
mapseq {
    "<Leader>ttp",
    "Find all high priority entries",
    function() telescope.todos({ priority = true }) end,
    mode = "n",
}

mapseq { "<Leader>sg", "Open project search", search.open, mode = "n" }
mapseq { "<Leader>sc", "Open search in current buffer", search.current_buffer, mode = "n" }
mapseq { "<Leader>swg", "Search current word in project", search.word, mode = "n" }
mapseq { "<Leader>swc", "Search current word in current buffer", search.word_in_current_buffer, mode = "n" }

map { "<C-l>", "Toggle LSP diagnostic lines", lsp.toggle_lines, mode = "n" }
map {
    "<C-,>",
    "List LSP diagnostics with ERROR severity for the whole workspace",
    function() telescope.diagnostics({ min_severity = "ERROR", current_buffer = false }) end,
    mode = { "n", "v" },
}
map {
    "<C-.>",
    "List LSP diagnostics with WARN & ERROR severities for the whole workspace",
    function() telescope.diagnostics({ min_severity = "WARN", current_buffer = false }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>da",
    "List all LSP diagnostics for the whole workspace",
    function() telescope.diagnostics({ current_buffer = false }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>de",
    "List LSP diagnostics with ERROR severity for the whole workspace",
    function() telescope.diagnostics({ min_severity = "ERROR", current_buffer = false }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>dw",
    "List LSP diagnostics with WARN & ERROR severities for the whole workspace",
    function() telescope.diagnostics({ min_severity = "WARN", current_buffer = false }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>dca",
    "List all LSP diagnostics for the current buffer only",
    function() telescope.diagnostics({ current_buffer = true }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>dce",
    "List LSP diagnostics with ERROR severity for the current buffer only",
    function() telescope.diagnostics({ min_severity = "ERROR", current_buffer = true }) end,
    mode = { "n", "v" },
}
mapseq {
    "<Leader>dcw",
    "List LSP diagnostics with WARN & ERROR severities for the current buffer only",
    function() telescope.diagnostics({ min_severity = "WARN", current_buffer = true }) end,
    mode = { "n", "v" },
}

mapseq { "<D-p>p", "Open plugins manager", "<Cmd>Lazy<CR>", mode = "n" }
mapseq { "<D-p>l", "Open package manager", "<Cmd>Mason<CR>", mode = "n" }

map { "<D-e>", "Open file tree", filetree.open_file_tree, mode = { "n", "v" } }
map { "<C-e>", "Open file browser", telescope.open_file_browser, mode = { "n", "i", "v" } }

mapseq { "<M-t>t", "Toggle tab terminal", terminal.toggle_tab, mode = { "n", "i", "v", "t" } }
mapseq { "<M-t>f", "Toggle float terminal", terminal.toggle_float, mode = { "n", "i", "v", "t" } }
mapseq { "<M-t>h", "Toggle horizontal terminal", terminal.toggle_horizontal, mode = { "n", "i", "v", "t" } }
map { "<D-Esc>", "Exit terminal mode", "<C-\\><C-n>", mode = "t" }

mapseq { "<D-g>g", "Git: Show lazygit", "<Cmd>LazyGit<CR>", mode = "n" }
mapseq { "<D-g>d", "Git: Toggle diff", git.toggle_diff, mode = "n" }
mapseq { "<D-g>t", "Git: open change file tree", filetree.open_git_tree, mode = { "n", "v" } }
map { "<D-j>", "Git: Jump to the next hunk", "<Cmd>Gitsigns next_hunk<CR>", mode = "n" }
map { "<D-k>", "Git: Jump to the previous hunk", "<Cmd>Gitsigns prev_hunk<CR>", mode = "n" }
mapseq { "<D-g>b", "Git: Show line blame", "<Cmd>Gitsigns blame_line<CR>", mode = "n" }
map { "<C-Space>", "Git: Stage hunk", "<Cmd>Gitsigns stage_hunk<CR>", mode = { "n", "v" } }
map { "<D-C-Space>", "Git: Unstage hunk", "<Cmd>Gitsigns undo_stage_hunk<CR>", mode = { "n", "v" } }

map { "<M-l>", "Toggle filename in statusline", statusline.toggle_filename, mode = { "n", "i", "v" } }

map { "<D-C-h>", "LSP: Jump to definition", "<Cmd>Lspsaga goto_definition<CR>", mode = "n" }
map { "<D-r>", "LSP: Rename", "<Cmd>Lspsaga rename<CR>", mode = "n" }
map { "<D-o>", "LSP: Workspace symbols", telescope.workspace_symbols, mode = "n" }
map { "<C-o>", "LSP: Document symbols", telescope.document_symbols, mode = "n" }
map { "<C-a>", "LSP: Code actions", "<Cmd>Lspsaga code_action<CR>", mode = "n" }
map { "<C-i>", "LSP: Hint", "<Cmd>Lspsaga hover_doc<CR>", mode = "n" }
map { "<C-f>", "LSP: Finder", "<Cmd>Lspsaga finder<CR>", mode = "n" }
map { "}", "LSP: Diagnostic next error", lsp.jump_to_next_error, mode = "n" }
map { "{", "LSP: Diagnostic previous error", lsp.jump_to_prev_error, mode = "n" }
map { "<C-}>", "LSP: Diagnostic next warning", lsp.jump_to_next_warning, mode = "n" }
map { "<C-{>", "LSP: Diagnostic previous warning", lsp.jump_to_prev_warning, mode = "n" }
