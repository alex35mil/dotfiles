local M = {}

function M.setup()
    require("nvim-surround").setup {
        keymaps = {
            insert = "<C-s>s",
            insert_line = "<C-s>S",
            normal = "ys",
            normal_cur = "yss",
            normal_line = "yS",
            normal_cur_line = "ySS",
            visual = "<C-s>",
            visual_line = "gS",
            delete = "ds",
            change = "cs",
            change_line = "cS",
        },
    }
end

return M
