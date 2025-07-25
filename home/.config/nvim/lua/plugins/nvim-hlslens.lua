local fn = {}

NVHlslens = {
    "kevinhwang91/nvim-hlslens",
    keys = function()
        return {
            {
                "n",
                function()
                    fn.jump("n")
                end,
                mode = "n",
            },
            {
                "N",
                function()
                    fn.jump("N")
                end,
                mode = "n",
            },
            {
                "*",
                [[<Cmd>keepjumps normal! mz*`z<CR><Cmd>delmarks z<CR><Cmd>lua require('hlslens').start()<CR>]],
                mode = "n",
            },
            {
                "#",
                [[<Cmd>keepjumps normal! mz#`z<CR><Cmd>delmarks z<CR><Cmd>lua require('hlslens').start()<CR>]],
                mode = "n",
            },
            {
                "g*",
                [[<Cmd>keepjumps normal! mzg*`z<CR><Cmd>delmarks z<CR><Cmd>lua require('hlslens').start()<CR>]],
                mode = "n",
            },
            {
                "g#",
                [[<Cmd>keepjumps normal! mzg#`z<CR><Cmd>delmarks z<CR><Cmd>lua require('hlslens').start()<CR>]],
                mode = "n",
            },
            {
                "*",
                [["*y:silent! let searchTerm = '\V'.substitute(escape(@*, '\/'), "\n", '\\n', "g") <Bar> let @/ = searchTerm <Bar> echo '/'.@/ <Bar> call histadd("search", searchTerm) <Bar> set hls<CR><Cmd>lua require('hlslens').start()<CR>]],
                mode = "v",
            },
        }
    end,
    opts = {},
}

---@param direction "n" | "N"
function fn.jump(direction)
    if vim.fn.getreg("/") ~= "" then
        local ok, _ = pcall(function()
            vim.cmd("normal! " .. vim.v.count1 .. direction)
        end)
        if ok then
            require("hlslens").start()
        else
            log.warn("Pattern not found: " .. vim.fn.getreg("/"))
        end
    end
end

return { NVHlslens }
