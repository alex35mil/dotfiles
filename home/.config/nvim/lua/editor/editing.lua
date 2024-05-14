local M = {}
local m = {}

function M.keymaps()
    K.map { "<D-c>", "Copy selected text", [["+y]], mode = "v" }
    K.map { "<D-v>", "Paste text", "P", mode = { "n", "v" } }
    K.map { "<D-v>", "Paste text", m.paste, mode = { "i", "c" } }

    K.map {
        "p",
        "Don't replace clipboard content when pasting",
        function() return 'pgv"' .. vim.v.register .. "ygv" end,
        mode = "v",
        expr = true,
    }

    K.map { "d", "Don't replace clipboard content when deleting", [["_d]], mode = { "n", "v" } }
    K.map { "D", "Don't replace clipboard content when deleting", [["_D]], mode = { "n", "v" } }
    K.map { "s", "Don't replace clipboard content when inserting", [["xs]], mode = "v" }
    K.map { "c", "Don't replace clipboard content when changing", [["xc]], mode = { "n", "v" } }

    K.map { "<CR>", "Change inner word", [["xciw]], mode = "n" }
    K.map { "<CR>", "Change seletion", [["xc]], mode = "v" }
    K.map { "<D-CR>", "Change inner word", [[<Esc>"xciw]], mode = "i" }
    K.map { "<M-w>", "Select inner word", "viw", mode = "n" }
    K.map { "<M-y>", "Yank inner word", "yiw", mode = "n" }

    K.map { "<S-Del>", "Insert new line above", "O<Esc>", mode = "n" }
    K.map { "<S-CR>", "Insert new line below", "o<Esc>", mode = "n" }
    K.map { "<S-Del>", "Insert new line above", "<Esc>O", mode = "i" }
    K.map { "<S-CR>", "Insert new line below", "<Esc>o", mode = "i" }

    K.map { "<D-d>", "Duplicate line", [["yyy"yp]], mode = "n" }
    K.map { "<D-d>", "Duplicate line", [[<Esc>"yyy"ypgi]], mode = "i" }
    K.map { "<D-d>", "Duplicate selection", [["yy'>"ypgv]], mode = "v" }

    K.map { "<M-Up>", "Move line up", "<Cmd>m .-2<CR>==", mode = "n" }
    K.map { "<M-Down>", "Move line down", "<Cmd>m .+1<CR>==", mode = "n" }
    K.map { "<M-Up>", "Move line up", "<Esc><Cmd>m .-2<CR>==gi", mode = "i" }
    K.map { "<M-Down>", "Move line down", "<Esc><Cmd>m .+1<CR>==gi", mode = "i" }
    K.map { "<M-Up>", "Move selected lines up", ":m '<-2<CR>gv=gv", mode = "v" }
    K.map { "<M-Down>", "Move selected lines down", ":m '>+1<CR>gv=gv", mode = "v" }

    K.map { "<Tab>", "Indent", ">>", mode = "n" }
    K.map { "<S-Tab>", "Unindent", "<<", mode = "n" }
    K.map { "<Tab>", "Indent", ">gv", mode = "v" }
    K.map { "<S-Tab>", "Unindent", "<gv", mode = "v" }

    K.map { "<M-Left>", "Jump one word to the left", "b", mode = { "n", "v" } }
    K.map { "<M-Right>", "Jump one word to the right", "w", mode = { "n", "v" } }
    K.map { "<M-Left>", "Jump one word to the left", "<C-o>b", mode = "i" }
    K.map { "<M-Right>", "Jump one word to the right", m.jump_to_end_of_word, mode = "i" }
    K.map { "<D-Left>", "Jump to the beginning of the line", "<C-o>I", mode = "i" }
    K.map { "<D-Right>", "Jump to the end of the line", "<C-o>A", mode = "i" }
    K.map { "<M-BS>", "Delete word to the left", "<C-w>", mode = "i" }
    K.map { "<M-Del>", "Delete word to the right", [[<C-o>"_de]], mode = "i" }
    K.map { "<D-BS>", "Delete everything to the left", "<C-u>", mode = "i" }
    K.map { "<D-Del>", "Delete everything to the right", [[<C-o>"_D]], mode = "i" }

    K.map { "<D-a>", "Select all", "ggVG", mode = "n" }
    K.map { "<D-a>", "Select all", "<Esc>ggVG", mode = { "i", "v" } }

    K.map { "*", "Don't jump on *", "<Cmd>keepjumps normal! mi*`i<CR>", mode = "n" }
    K.map {
        "*",
        "Highlight selected text",
        [["*y:silent! let searchTerm = '\V'.substitute(escape(@*, '\/'), "\n", '\\n', "g") <bar> let @/ = searchTerm <bar> echo '/'.@/ <bar> call histadd("search", searchTerm) <bar> set hls<cr>]],
        mode = "v",
    }

    -- With Noice, cearing the command line doesn't make sense. Replacing it with just `noh`.
    -- K.map { "<Esc>", "Drop search highlight and clear the command line", "<Cmd>silent noh<CR>:<BS>", mode = "n", silent = false }
    K.map { "<Esc>", "Drop search highlight", "<Cmd>silent noh<CR>", mode = "n", silent = false }

    K.map { "u", "Unset undo", "<Nop>", mode = "n" }
    K.map { "<D-u>", "Undo", "u", mode = { "n", "v" } }
    K.map { "<D-u>", "Undo", "<Esc>ui", mode = "i" }
    K.map { "<D-r>", "Redo", "<C-r>", mode = { "n", "v" } }
    K.map { "<D-r>", "Redo", "<Esc><C-r>i", mode = "i" }

    K.map { "<D-s>", "Save files", "<Cmd>silent w<CR><Cmd>silent! wa<CR>", mode = "n" }
    K.map { "<D-s>", "Save files", "<Esc><Cmd>silent w<CR><Cmd>silent! wa<CR>", mode = { "i", "v" } }
end

-- Private

function m.paste()
    local keys = require "editor.keys"

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

function m.jump_to_end_of_word()
    vim.cmd("normal! e")

    local current_col = vim.fn.col(".")
    local end_col = vim.fn.col("$")

    if current_col == end_col - 1 then
        local keys = require "editor.keys"
        keys.send("<Esc>A", { mode = "n" })
    elseif current_col ~= end_col then
        vim.cmd("normal! l")
    end
end

return M
