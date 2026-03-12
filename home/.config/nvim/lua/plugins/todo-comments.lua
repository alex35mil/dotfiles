local Picker = {}

NVTodoComments = {
    "folke/todo-comments.nvim",
    event = "BufEnter",
    keys = function()
        return {
            {
                "<C-S-r>",
                function()
                    Picker.list({ "TODO!", "FIXME!" })
                end,
                mode = "n",
                desc = "Show TODOs",
            },
            {
                "<Leader>tt",
                function()
                    Picker.list({ "TODO!", "TODO" })
                end,
                mode = "n",
                desc = "Show TODO!s",
            },
            {
                "<Leader>tf",
                function()
                    Picker.list({ "FIXME!", "FIXME" })
                end,
                mode = "n",
                desc = "Show FIXMEs",
            },
        }
    end,
    opts = {
        keywords = {
            TODO = { icon = " ", color = "todo_normal" },
            TODO_NOW = { icon = " ", color = "todo_now", alt = { "TODO!" } },
            FIXME = { icon = " ", color = "fixme_normal", alt = { "FIX", "BUG" } },
            FIXME_NOW = { icon = " ", color = "fixme_now", alt = { "FIXME!" } },
            HACK = { icon = " ", color = "warning_normal" },
            WARN = { icon = " ", color = "warning_normal", alt = { "WARNING", "XXX" } },
            PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "note_normal", alt = { "INFO" } },
            TEST = { icon = "⏲ ", color = "note_normal", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        colors = {
            todo_now = { "TODONow" },
            todo_normal = { "TODONormal" },
            fixme_now = { "FIXMENow" },
            fixme_normal = { "FIXMENormal" },
            note_normal = { "NOTENormal" },
            warning_normal = { "WARNNormal" },
        },
        highlight = {
            pattern = [=[.*<((KEYWORDS)[!?]?(\([^)]*\)|\[[^]]*\])?)\s*:]=],
        },
        search = {
            pattern = [=[\b(KEYWORDS)[!?]?(\([^)]*\)|\[[^\]]*\])?:]=],
        },
        merge_keywords = false,
    },
}

---@param types ("TODO" | "TODO!" | "FIXME" | "FIXME!")[]
function Picker.list(types)
    local trouble = require("trouble")

    local tags = vim.tbl_map(function(t)
        return t:gsub("!", "_NOW")
    end, types)

    trouble.open({
        mode = "todo",
        focus = true,
        filter = { tag = tags },
        win = { position = "top", size = 0.4 },
        groups = {
            { "directory" },
            { "filename", format = "{file_icon} {basename} {count}" },
        },
    })
end

return { NVTodoComments }
