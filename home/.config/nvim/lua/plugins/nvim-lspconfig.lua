NVLSPConfig = {
    "neovim/nvim-lspconfig",
    opts = function()
        local keys = require("lazyvim.plugins.lsp.keymaps").get()

        keys[#keys + 1] = { "<D-r>", vim.lsp.buf.rename }
        keys[#keys + 1] = { "<C-a>", vim.lsp.buf.code_action }
    end,
}

return { NVLSPConfig }
