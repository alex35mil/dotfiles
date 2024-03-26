local autocmds = {
    {
        { "VimEnter" },
        {
            callback = function()
                if vim.v.vim_did_enter then
                    vim.cmd "LualineRenameTab editor"
                end
            end,
        },
    },
    {
        { "BufEnter" },
        {
            pattern = "*",
            callback = function()
                if vim.bo.ft == "help" then
                    vim.api.nvim_command("wincmd L")
                end
            end,
        },
    },
    { { "BufEnter" },    { pattern = { "*.md", "*.mdx" }, command = "setlocal wrap" } },
    { { "Filetype" },    { pattern = "markdown", command = "lua vim.b.minitrailspace_disable = true" } },
    { { "Filetype" },    { pattern = "rescript", command = "setlocal commentstring=//%s" } },
    { { "TermOpen" },    { pattern = "*", command = "lua vim.b.minitrailspace_disable = true" } },
    { { "FocusGained" }, { pattern = "*", command = "checktime" } },
    {
        { "FocusLost" },
        {
            pattern = "*",
            callback = function()
                vim.cmd "silent! wa"
            end,
        },
    },
    {
        { "User" },
        {
            pattern = "AlphaReady",
            callback = require("plugins.alpha").on_open,
        },
    },
    {
        { "User" },
        {
            pattern = "AlphaClosed",
            callback = require("plugins.alpha").on_close,
        },
    },
    {
        { "User" },
        {
            pattern = "LazyVimStarted",
            once = true,
            callback = require("plugins.alpha").update_footer,
        },
    },
    {
        { "User" },
        {
            pattern = "ThemeApplied",
            callback = function() print "Theme applied" end,
        },
    },
}

for _, x in ipairs(autocmds) do
    for _, event in ipairs(x[1]) do
        vim.api.nvim_create_autocmd(event, x[2])
    end
end
