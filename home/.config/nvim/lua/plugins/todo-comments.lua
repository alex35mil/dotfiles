NVTodoComments = {
    "folke/todo-comments.nvim",
    opts = {
        keywords = {
            FIXME = { icon = " ", color = "error", alt = { "FIX", "BUG" } },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        highlight = {
            pattern = [=[.*<((KEYWORDS)[!?]?(\([^)]*\)|\[[^]]*\])?)\s*:]=],
        },
        search = {
            pattern = [=[\b(KEYWORDS)[!?]?(\([^)]*\)|\[[^\]]*\])?:]=],
        },
    },
}

return { NVTodoComments }
