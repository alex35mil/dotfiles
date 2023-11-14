local M = {}

M.search = {
    cmd = "rg",
    base_args = {
        "--follow",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
    },
    optional_args = {
        with_hidden = "--hidden",
        with_ignored = "--no-ignore-vcs",
        smart_case = "--smart-case",
        ignore_case = "--ignore-case",
    },
}

M.replace = {
    cmd = "sed",
    args = nil,
}

return M
