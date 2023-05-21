-- https://neovim.io/doc/user/api.html#nvim_create_user_command()

local create = vim.api.nvim_create_user_command

create("XTodo", "TodoTelescope keywords=TODO,FIXME layout_strategy=vertical initial_mode=normal", {})

-- autocmds

local autocmds = {
    {
        { "VimEnter" },
        {
            callback = function()
                if vim.v.vim_did_enter then
                    local view = require "utils.view"
                    local windows = view.get_tab_windows_with_listed_buffers()

                    if #windows == 1 then
                        require("utils.zenmode").toggle()
                    else
                        require("nvim-tree.api").tree.open()
                    end

                    vim.cmd "LualineRenameTab editor"
                end
            end,
        },
    },
    { { "BufEnter" }, { pattern = { "*.md", "*.mdx" }, command = "setlocal wrap" } },
    { { "Filetype" }, { pattern = "markdown", command = "lua vim.b.minitrailspace_disable = true" } },
    { { "TermOpen" }, { pattern = "*", command = "lua vim.b.minitrailspace_disable = true" } },
    {
        { "FocusLost" },
        {
            pattern = "*",
            callback = function()
                -- for some reason, ++nested doesn't trigger BufWritePre
                -- also, when loosing focus when filetree is active, neovide panics - hence `silent!`
                vim.cmd "silent! doautocmd BufWritePre <afile>"
                vim.cmd "silent! wa"
            end,
        },
    },
    {
        { "BufWritePre" },
        {
            pattern = "*",
            callback = function()
                local filetype = vim.bo.filetype
                local clients = vim.lsp.get_active_clients()

                local client

                for _, c in ipairs(clients) do
                    if c.config ~= nil and c.config.filetypes ~= nil then
                        for _, ft in ipairs(c.config.filetypes) do
                            if ft == filetype and c.server_capabilities.documentFormattingProvider then
                                client = c
                                break
                            end
                        end
                    end

                    if client then
                        break
                    end
                end

                if client then
                    vim.lsp.buf.format { async = false }
                else
                    local bufname = vim.fn.expand "<afile>"
                    local bufnr = vim.fn.bufnr(bufname)

                    if bufnr == -1 then return end

                    local modifiable = vim.api.nvim_buf_get_option(bufnr, "modifiable")

                    if modifiable then
                        local trimmer = require "mini.trailspace"

                        vim.api.nvim_buf_set_lines(0, 0, vim.fn.nextnonblank(1) - 1, true, {})

                        if filetype ~= "markdown" then
                            trimmer.trim()
                        end

                        trimmer.trim_last_lines()
                    end
                end
            end,
        },
    },
}

for _, c in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(c[1], c[2])
end
