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
                    local windows = view.get_tab_windows_without_filetree()

                    if #windows == 1 then
                        require("utils.zenmode").activate()
                    else
                        require("nvim-tree.api").tree.open()
                    end
                end
            end,
        },
    },
    { { "BufEnter" }, { pattern = { "*.md", "*.mdx" }, command = "setlocal wrap" } },
    { { "Filetype" }, { pattern = "markdown", command = "lua vim.b.minitrailspace_disable = true" } },
    { { "TermOpen" }, { pattern = "*", command = "lua vim.b.minitrailspace_disable = true" } },
    { { "FocusLost" }, { pattern = "*", command = "silent! wa" } },
    {
        { "BufWritePre" },
        {
            pattern = "*",
            callback = function()
                local filetype = vim.bo.filetype
                local clients = vim.lsp.get_active_clients()

                local client

                for _, c in ipairs(clients) do
                    for _, ft in ipairs(c.config.filetypes) do
                        if ft == filetype then
                            client = c
                            break
                        end
                    end

                    if client then
                        break
                    end
                end

                if client and client.server_capabilities.documentFormattingProvider then
                    vim.lsp.buf.format { async = false }
                else
                    local trimmer = require "mini.trailspace"

                    vim.api.nvim_buf_set_lines(0, 0, vim.fn.nextnonblank(1) - 1, true, {})

                    if filetype ~= "markdown" then
                        trimmer.trim()
                    end

                    trimmer.trim_last_lines()

                end
            end,
        },
    },
}

for _, c in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(c[1], c[2])
end
