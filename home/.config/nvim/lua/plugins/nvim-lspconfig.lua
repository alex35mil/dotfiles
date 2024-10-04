NVLspConfig = {
    "neovim/nvim-lspconfig",
    opts = function()
        local lazy_keymaps = require("lazyvim.plugins.lsp.keymaps").get()
        vim.list_extend(lazy_keymaps, NVLsp.keymaps())
    end,
}

return { NVLspConfig }
