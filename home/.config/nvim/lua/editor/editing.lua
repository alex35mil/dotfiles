NVEditing = {}

local fn = {}

function NVEditing.keymaps()
    K.map({ "<D-c>", "Copy selected text", [["+y]], mode = "v" })
    K.map({ "<D-v>", "Paste text", "P", mode = { "n", "v" } })
    K.map({ "<D-v>", "Paste text", fn.paste, mode = { "i", "c" } })

    K.map({
        "p",
        "Don't replace clipboard content when pasting",
        function()
            return 'pgv"' .. vim.v.register .. "ygv"
        end,
        mode = "v",
        expr = true,
    })

    K.map({ "d", "Don't replace clipboard content when deleting", [["_d]], mode = { "n", "v" } })
    K.map({ "D", "Don't replace clipboard content when deleting", [["_D]], mode = { "n", "v" } })
    K.map({ "s", "Don't replace clipboard content when inserting", [["xs]], mode = "v" })
    K.map({ "c", "Don't replace clipboard content when changing", [["xc]], mode = { "n", "v" } })

    K.map({ "<CR>", "Change inner word", [["xciw]], mode = "n" })
    K.map({ "<CR>", "Change seletion", [["xc]], mode = "v" })
    K.map({ "<M-CR>", "Change inner word", [[<Esc>"xciw]], mode = "i" })
    K.map({ "<M-w>", "Select inner word", "viw", mode = "n" })
    K.map({ "<M-y>", "Yank inner word", "yiw", mode = "n" })

    K.map({ "<D-CR>", "Insert new line above", "O<Esc>", mode = "n" })
    K.map({ "<S-CR>", "Insert new line below", "o<Esc>", mode = "n" })
    K.map({ "<D-CR>", "Insert new line above", "<Esc>O", mode = "i" })
    K.map({ "<S-CR>", "Insert new line below", "<Esc>o", mode = "i" })

    K.map({ "<D-d>", "Duplicate line", [["yyy"yp]], mode = "n" })
    K.map({ "<D-d>", "Duplicate line", [[<Esc>"yyy"ypgi]], mode = "i" })
    K.map({ "<D-d>", "Duplicate selection", [["yy'>"ypgv]], mode = "v" })

    K.map({ "<M-Up>", "Move line up", "<Cmd>m .-2<CR>==", mode = "n" })
    K.map({ "<M-Down>", "Move line down", "<Cmd>m .+1<CR>==", mode = "n" })
    K.map({ "<M-Up>", "Move line up", "<Esc><Cmd>m .-2<CR>==gi", mode = "i" })
    K.map({ "<M-Down>", "Move line down", "<Esc><Cmd>m .+1<CR>==gi", mode = "i" })
    K.map({ "<M-Up>", "Move selected lines up", ":m '<-2<CR>gv=gv", mode = "v" })
    K.map({ "<M-Down>", "Move selected lines down", ":m '>+1<CR>gv=gv", mode = "v" })

    K.map({ "<Tab>", "Indent", ">>", mode = "n" })
    K.map({ "<S-Tab>", "Unindent", "<<", mode = "n" })
    K.map({ "<Tab>", "Indent", ">gv", mode = "v" })
    K.map({ "<S-Tab>", "Unindent", "<gv", mode = "v" })

    K.map({ "<M-Left>", "Jump one word to the left", "<Cmd>lua require('spider').motion('b')<CR>", mode = { "n", "v" } })
    K.map({
        "<M-Right>",
        "Jump one word to the right",
        "<Cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "v" },
    })
    K.map({ "<M-Left>", "Jump one word to the left", "<C-o><Cmd>lua require('spider').motion('b')<CR>", mode = "i" })
    K.map({ "<M-Right>", "Jump one word to the right", fn.jump_to_end_of_word, mode = "i" })
    K.map({ "<D-Left>", "Jump to the beginning of the line", "<C-o>I", mode = "i" })
    K.map({ "<D-Right>", "Jump to the end of the line", "<C-o>A", mode = "i" })
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
            if vim.bo.filetype ~= "snacks_input" and vim.bo.filetype ~= "snacks_picker_input" then
                K.map({ "<M-BS>", "Delete word to the left", "<C-w>", mode = "i", buffer = true })
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "snacks_input", "snacks_picker_input" },
        callback = function()
            K.map({ "<M-BS>", "Delete word to the left", "<C-S-w>", mode = "i", buffer = true })
        end,
    })
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        pattern = "*",
        callback = function()
            K.map({
                "<M-BS>",
                "Delete word to the left",
                function()
                    NVKeys.send("<C-w>", { mode = "n" })
                    vim.schedule(function()
                        vim.cmd("redraw")
                    end)
                end,
                mode = "c",
                buffer = true,
            })
        end,
    })
    K.map({ "<M-Del>", "Delete word to the right", [[<C-o>"_de]], mode = "i" })
    K.map({ "<D-BS>", "Delete everything to the left", "<C-u>", mode = "i" })
    K.map({ "<D-Del>", "Delete everything to the right", [[<C-o>"_D]], mode = "i" })

    K.map({ "<D-S-CR>", "Split line in three", "i<CR><Esc>O", mode = "n" })
    K.map({ "<D-S-CR>", "Split line in three", "<CR><Esc>O", mode = "i" })

    K.map({ "<D-a>", "Select all", "ggVG", mode = "n" })
    K.map({ "<D-a>", "Select all", "<Esc>ggVG", mode = { "i", "v" } })

    K.map({
        "<Esc>",
        "Drop all the noise and Esc",
        "<Cmd>lua NVEditing.esc()<CR><Esc>",
        mode = "n",
        silent = false,
    })

    K.map({ "u", "Unset undo", "<Nop>", mode = "n" })
    K.map({ "<D-u>", "Undo", "u", mode = { "n", "v" } })
    K.map({ "<D-u>", "Undo", "<Esc>ui", mode = "i" })
    K.map({ "<D-S-u>", "Redo", "<C-r>", mode = { "n", "v" } })
    K.map({ "<D-S-u>", "Redo", "<Esc><C-r>i", mode = "i" })

    K.map({ "<D-{>", "Comment", "gcc", mode = "n", remap = true })
    K.map({ "<D-{>", "Comment", "gc", mode = "v", remap = true })
    K.map({ "<D-{>", "Comment", "<Cmd>normal gcc<CR>", mode = "i", remap = true })
    K.map({ "<D-}>", "Start comment on the next line", "oo<Esc><Cmd>normal gcc<CR>A<BS>", mode = "n", remap = true })
    K.map({
        "<D-}>",
        "Start comment on the next line",
        "<Esc>oo<Esc><Cmd>normal gcc<CR>A<BS>",
        mode = "i",
        remap = true,
    })

    K.map({
        "<D-k>",
        "Save files",
        fn.save,
        mode = "n",
    })
    K.map({
        "<D-k>",
        "Save files",
        "<Cmd>lua NVEditing.esc()<CR><Esc><Cmd>silent w<CR><Cmd>silent! wa<CR>",
        mode = { "i", "v" },
    })
    -- Duplicates of the above so saving works with CAPS_WORD
    K.map({
        "<D-S-k>",
        "Save files",
        fn.save,
        mode = "n",
    })
    K.map({
        "<D-S-k>",
        "Save files",
        "<Cmd>lua NVEditing.esc()<CR><Esc><Cmd>silent w<CR><Cmd>silent! wa<CR>",
        mode = { "i", "v" },
    })
end

function NVEditing.esc()
    if NVLspPopup.ensure_hidden() then
        return
    end

    if NVMulticursor.esc() then
        return
    end

    NVSNotifier.hide()
    vim.cmd("silent noh")
end

function fn.save()
    NVEditing.esc()
    vim.cmd("silent w")
    vim.cmd("silent! wa")
end

function fn.paste()
    local mode = vim.fn.mode()

    if mode == "i" or mode == "c" then
        local paste = vim.o.paste
        local fopts = vim.o.formatoptions

        vim.o.paste = true
        vim.o.formatoptions = fopts:gsub("[crota]", "")

        NVKeys.send("<C-r>+", { mode = "n" })

        vim.defer_fn(function()
            vim.o.paste = paste
            vim.o.formatoptions = fopts
        end, 10)
    else
        log.error("Unexpected mode")
    end
end

function fn.jump_to_end_of_word()
    require("spider").motion("e")

    local current_col = vim.fn.col(".")
    local end_col = vim.fn.col("$")

    if current_col == end_col - 1 then
        NVKeys.send("<Esc>A", { mode = "n" })
    elseif current_col ~= end_col then
        vim.cmd("normal! l")
    end
end
