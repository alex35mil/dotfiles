NVIncline = {
    "b0o/incline.nvim",
    config = function()
        require("incline").setup({
            window = {
                zindex = 10,
            },
            hide = {
                cursorline = "smart",
                focused_win = true,
                only_win = false,
            },
            render = function(props)
                local devicons = require("nvim-web-devicons")

                local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                if filename == "" or filename == "null" then
                    filename = "-"
                end
                local ext = vim.fn.fnamemodify(filename, ":e")
                local devicon, _ = devicons.get_icon(filename, ext, { default = true })
                local modified = vim.bo[props.buf].modified
                return {
                    devicon and {
                        devicon,
                        " ",
                        guibg = NVTheme.palette.float_bg,
                        guifg = NVTheme.palette.faded_text,
                    } or "",
                    " ",
                    {
                        filename,
                        guibg = NVTheme.palette.float_bg,
                        guifg = NVTheme.palette.faded_text,
                        gui = modified and "bold,italic" or "bold",
                    },
                }
            end,
        })
    end,
}

function NVIncline.refresh()
    require("incline").refresh()
end

return { NVIncline }
