NVKeys = {}

---@param keys string
---@param options {mode: "n" | "x" | "t", from_part: boolean, do_lt: boolean, special: boolean}
function NVKeys.send(keys, options)
    local mode = options.mode

    if mode == nil then
        log.error("Sending keys requires mode")
        return
    end

    options.mode = nil

    if mode == "n" then
        local opts = vim.tbl_extend("keep", options, {
            from_part = true,
            do_lt = true,
            special = true,
        })

        local tc = vim.api.nvim_replace_termcodes(keys, opts.from_part, opts.do_lt, opts.special)

        vim.api.nvim_feedkeys(tc, mode, false)
    elseif mode == "x" then
        local opts = vim.tbl_extend("keep", options, {
            from_part = true,
            do_lt = false,
            special = true,
        })

        local tc = vim.api.nvim_replace_termcodes(keys, opts.from_part, opts.do_lt, opts.special)

        vim.api.nvim_feedkeys(tc, mode, false)
    elseif mode == "t" then
        vim.api.nvim_feedkeys(keys, mode, false)
    else
        log.error("Unexpected mode")
    end
end
