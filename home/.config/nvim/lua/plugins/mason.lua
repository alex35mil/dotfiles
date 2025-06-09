local fn = {}

NVMason = {
    "mason-org/mason.nvim",
    keys = function()
        return {
            { "<Leader>m", fn.show, mode = "n", desc = "Show mason" },
        }
    end,
    opts = {
        ui = {
            width = NVScreen.is_large() and 0.8 or 0.9,
            height = 0.85,
            backdrop = 100,
        },
    },
}

function fn.show()
    vim.cmd("Mason")
end

function NVMason.ensure_hidden()
    if vim.bo.filetype == "mason" then
        vim.cmd.close()
        return true
    end
    return false
end

return { NVMason }
