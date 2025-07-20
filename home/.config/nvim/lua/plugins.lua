local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins/" },
        { import = "plugins/ai/" },
        { import = "plugins/lsp/" },
        { import = "plugins/lsp/languages/" },
    },
    install = {
        missing = false,
        colorscheme = { "hyper" },
    },
    ui = {
        backdrop = 100,
    },
    checker = {
        enabled = true, -- check for plugin updates periodically
        notify = false, -- don't notify on update
    },
})
