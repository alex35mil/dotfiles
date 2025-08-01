NVUfo = {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
        provider_selector = function(_, _, _)
            return { "treesitter", "indent" }
        end,
    },
}

return { NVUfo }
