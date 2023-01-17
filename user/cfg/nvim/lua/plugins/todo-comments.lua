local plugin = require "todo-comments"

plugin.setup {
    signs = false,
    colors = {
        todo = { "TodoComment" },
        fixme = { "FixmeComment" },
    },
    keywords = {
        TODO = { icon = "", color = "todo" },
        FIX = { icon = "", color = "fixme", alt = { "FIXME" } },
        NB = { icon = "", color = "hint", alt = { "NB!" } },
    },
    search = {
        command = "rg",
        args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--hidden",
        },
    },
}
