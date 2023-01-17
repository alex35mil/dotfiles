local plugin = require "indent_blankline"

plugin.setup {
    indentLine_enabled = 1,
    show_trailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    show_current_context_start = true,
}
