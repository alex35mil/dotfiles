local plugin = require "Comment"

plugin.setup {
    -- Add a space b/w comment and the line
    padding = true,
    -- Whether the cursor should stay at its position
    sticky = true,
    -- LHS of toggle mappings in NORMAL mode
    toggler = {
        -- Line-comment toggle keymap
        line = "gc",
        -- Block-comment toggle keymap
        block = "<Leader>bc",
    },
    -- LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
        -- Line-comment keymap
        line = "gc",
        -- Block-comment keymap
        block = "<Leader>bc",
    },
    -- LHS of extra mappings
    extra = {
        -- Add comment on the line above
        above = "<Leader>ck",
        -- Add comment on the line below
        below = "<Leader>cj",
        -- Add comment at the end of line
        eol = "<Leader>cl",
    },
    -- Enable keybindings
    mappings = {
        basic = true,
        extra = true,
    },
    ---Function to call before (un)comment
    pre_hook = nil,
    ---Function to call after (un)comment
    post_hook = nil,
}
