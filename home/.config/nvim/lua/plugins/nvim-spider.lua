NVSpider = {
    "chrisgrieser/nvim-spider",
    lazy = true,
    keys = {
        { "w", "<Cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" } },
        { "e", "<Cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" } },
        { "b", "<Cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" } },
        { "ge", "<Cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" } },
    },
}

return { NVSpider }
