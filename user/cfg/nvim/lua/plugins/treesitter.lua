local plugin = require "nvim-treesitter.configs"

plugin.setup {
    highlight = {
        enable = true,
        use_languagetree = true,
    },
    indent = {
        enable = true,
    },
    ensure_installed = {
        "bash",
        "css",
        "diff",
        "dockerfile",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "graphql",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "ocaml",
        "ocaml_interface",
        "rust",
        "scss",
        "sql",
        "swift",
        "toml",
        "typescript",
        "yaml",
    },
    textobjects = {
        select = {
            enable = true,
        },
    },
}
