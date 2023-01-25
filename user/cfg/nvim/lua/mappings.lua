local editor = require "mappings.editor"
local git = require "mappings.git"
local telescope = require "mappings.telescope"
local statusline = require "mappings.statusline"

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

---@format disable

-- NB!: `which-key` freaks out when `mode = ""`
-- NB!: sometimes, when arg to `map` has multiple keys, one or more keys don't apply

map { ["<M-k>"] = { "Insert new line above", "O<Esc>", mode = "n" } }
map { ["<M-j>"] = { "Insert new line below", "o<Esc>", mode = "n" } }
map { ["<M-k>"] = { "Insert new line above", "<Esc>O", mode = "i" } }
map { ["<M-j>"] = { "Insert new line below", "<Esc>o", mode = "i" } }

map { ["<M-d>"] = { "Duplicate line", "yyp",      mode = "n" } }
map { ["<M-d>"] = { "Duplicate line", "<Esc>yyp", mode = "i" } }
map { ["<M-d>"] = { "Duplicate line", "y'>p",     mode = "v" } }

map { ["<M-Up>"]   = { "Move line up",   "<Cmd>m .-2<CR>==",        mode = "n" } }
map { ["<M-Down>"] = { "Move line down", "<Cmd>m .+1<CR>==",        mode = "n" } }
map { ["<M-Up>"]   = { "Move line up",   "<Esc><Cmd>m .-2<CR>==gi", mode = "i" } }
map { ["<M-Down>"] = { "Move line down", "<Esc><Cmd>m .+1<CR>==gi", mode = "i" } }
map { ["<M-Up>"]   = { "Move line up",   "<Cmd>m '<-2<CR>gv=gv",    mode = "v" } }
map { ["<M-Down>"] = { "Move line down", "<Cmd>m '>+1<CR>gv=gv",    mode = "v" } }

map { ["<Tab>"]   = { "Indent",   ">>",  mode = "n" } }
map { ["<M-Tab>"] = { "Unindent", "<<",  mode = "n" } }
map { ["<Tab>"]   = { "Indent",   ">gv", mode = "v" } }
map { ["<M-Tab>"] = { "Unindent", "<gv", mode = "v" } }

map { ["<C-a>"] = { "Select all", "ggVG",      mode = "n"          } }
map { ["<C-a>"] = { "Select all", "<Esc>ggVG", mode = { "i", "v" } } }

map { ["<C-k>"] = { "Move cursor half-screen up",   "<C-u>", mode = "n" } }
map { ["<C-j>"] = { "Move cursor half-screen down", "<C-d>", mode = "n" } }

map { ["<C-h>h"] = { "Hop: 1 chars", "<Cmd>HopChar2<CR>", mode = { "n", "i", "v" } } }
map { ["<C-h>w"] = { "Hop: word",    "<Cmd>HopWord<CR>",  mode = { "n", "i", "v" } } }

map { ["<Leader>m"]   = { "History: back",                 "<C-o>",         mode = "n" } }
map { ["<Leader>,"]   = { "History: forward",              "<C-i>",         mode = "n" } }
map { ["<LeftMouse>"] = { "History: include mouse clicks", "m'<LeftMouse>", mode = "n" } }

map { ["*"]     = { "Don't jump on *",                                  "<Cmd>keepjumps normal! mi*`i<CR>", mode = "n"                 } }
map { ["<Esc>"] = { "Drop search highlight and clear the command line", "<Cmd>silent noh<CR>:<BS>",         mode = "n", silent = false } }

map { ["<C-u>"] = { "Undo", "<Esc>ui",     mode = "i" } }
map { ["<C-r>"] = { "Redo", "<Esc><C-r>i", mode = "i" } }

map { ["<C-c>"] = { "Toggle comments", "<Esc><Cmd>normal <C-c><CR>gi", mode = "i" } }

map { ["<C-s>"] = { "Save file", "<Cmd>w<CR>",      mode = "n"          } }
map { ["<C-s>"] = { "Save file", "<Esc><Cmd>w<CR>", mode = { "i", "v" } } }

map { ["<C-Left>"]  = { "Move to window on the left",  "<Cmd>wincmd h<CR>", mode = { "n", "t" } } }
map { ["<C-Down>"]  = { "Move to window below",        "<Cmd>wincmd j<CR>", mode = { "n", "t" } } }
map { ["<C-Up>"]    = { "Move to window above",        "<Cmd>wincmd k<CR>", mode = { "n", "t" } } }
map { ["<C-Right>"] = { "Move to window on the right", "<Cmd>wincmd l<CR>", mode = { "n", "t" } } }

map { ["<C-z>"]  = { "Toggle zen mode",                            editor.zenmode,                                                                mode = { "n", "i", "v"      } } }
map { ["<C-w>"]  = { "Close current buffer",                       editor.close_buffer,                                                           mode = { "n", "i", "v"      } } }
map { ["<M-w>w"] = { "Close all buffers except current & unsaved", function() editor.close_all_bufs_except_current({ incl_unsaved = false }) end, mode = { "n", "i", "v"      } } }
map { ["<M-w>a"] = { "Close all buffers except current",           function() editor.close_all_bufs_except_current({ incl_unsaved = true })  end, mode = { "n", "i", "v"      } } }
map { ["<C-q>"]  = { "Quit editor",                                editor.quit,                                                                   mode = { "n", "i", "v", "t" } } }

map { ["<C-o>"]  = { "Open file browser", telescope.browser, mode = { "n", "t" } } } -- FIXME: "t" needs proper cwd
map { ["<C-p>"]  = { "Find command",      telescope.command, mode = "n"          } }
map { ["<C-b>"]  = { "Find buffer",       telescope.buffer,  mode = "n"          } }
map { ["<C-f>f"] = { "Find file",         telescope.file,    mode = "n"          } }
map { ["<C-f>t"] = { "Find text",         telescope.text,    mode = "n"          } }

map { ["<Leader>e"] = { "Toggle file tree",       "<Cmd>NvimTreeToggle<CR>",   mode = { "n", "v" } } } -- NOTE: Requires disabling of the default keymap edit_in_place
map { ["<Leader>/"] = { "Find file in file tree", "<Cmd>NvimTreeindFile<CR>", mode = { "n", "v" } } }

map { ["<C-t>"] = { "Toggle terminal", "<Cmd>ToggleTerm<CR>", mode = { "n", "t" } } }

map { ["<C-g>"] = { "Git: Show lazygit", git.toggle,                       mode = "n" } }
map { ["<M-g>"] = { "Git: Stage buffer", "<Cmd>Gitsigns stage_buffer<CR>", mode = "n" } }

map { ["<M-l>"] = { "Toggle filename in statusline", statusline.toggle_filename, mode = { "n", "i", "v" } } }

map { ["<C-d>"]      = { "LSP: Toggle diagnostics",  "<Cmd>TroubleToggle<CR>",                mode = "n" } }
map { ["<Leader>j"]  = { "LSP: Jump to definition",  "<Cmd>Lspsaga goto_definition<CR>",      mode = "n" } }
map { ["<Leader>r"]  = { "LSP: Rename",              "<Cmd>Lspsaga rename<CR>",               mode = "n" } }
map { ["<Leader>o"]  = { "LSP: Outline",             "<Cmd>Lspsaga outline<CR>",              mode = "n" } }
map { ["<Leader>a"]  = { "LSP: Code actions",        "<Cmd>Lspsaga code_action<CR>",          mode = "n" } }
map { ["<Leader>h"]  = { "LSP: Hint",                "<Cmd>Lspsaga hover_doc<CR>",            mode = "n" } }
map { ["<Leader>f"]  = { "LSP: Finder",              "<Cmd>Lspsaga lsp_finder<CR>",           mode = "n" } }
map { ["<Leader>dj"] = { "LSP: Diagnostic next",     "<Cmd>Lspsaga diagnostic_jump_next<CR>", mode = "n" } }
map { ["<Leader>dk"] = { "LSP: Diagnostic previous", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", mode = "n" } }
