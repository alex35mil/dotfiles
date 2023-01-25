local plugin = require "nvim-surround"

plugin.setup {
    keymaps = {
        insert = "<M-s>s",
        insert_line = "<M-s>S",
        normal = "<M-s>s",
        normal_cur = "<M-s>ss",
        normal_line = "<M-s>S",
        normal_cur_line = "<M-s>SS",
        visual = "<M-s>S",
        visual_line = "<M-s>gS",
        delete = "<M-s>d",
        change = "<M-s>c",
    },
}
