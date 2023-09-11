local M = {}

function M.send(keys, options)
    if options.mode == nil then
        vim.api.nvim_err_writeln("Sending keys requires mode")
        return
    end

    if options.mode == "n" then
        local opts = vim.tbl_extend("keep", options, {
            from_part = true,
            do_lt = true,
            special = true,
        })

        local tc = vim.api.nvim_replace_termcodes(keys, opts.from_part, opts.do_lt, opts.special)

        vim.api.nvim_feedkeys(tc, opts.mode, false)
    elseif options.mode == "x" then
        local opts = vim.tbl_extend("keep", options, {
            from_part = true,
            do_lt = false,
            special = true,
        })

        local tc = vim.api.nvim_replace_termcodes(keys, opts.from_part, opts.do_lt, opts.special)

        vim.api.nvim_feedkeys(tc, opts.mode, false)
    elseif options.mode == "t" then
        vim.api.nvim_feedkeys(keys, options.mode, false)
    else
        vim.api.nvim_err_writeln("Unexpected mode")
    end
end

return M
