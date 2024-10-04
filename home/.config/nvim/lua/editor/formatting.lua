NVFormatting = {}

function NVFormatting.keymaps()
    K.map({
        "<C-f>",
        "Format",
        function()
            LazyVim.format({ force = true })
        end,
        mode = { "n", "v" },
    })
end

function NVFormatting.autocmds()
    vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "json", "toml", "yaml", "clojure" },
        callback = function()
            vim.b.autoformat = false
        end,
    })
end
