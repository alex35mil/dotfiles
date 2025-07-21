NVReScript = {
    {
        "neovim/nvim-lspconfig",
        opts = {
            tools = {
                rescriptls = { lsp = true },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "rescript",
            },
        },
    },
}

function NVReScript.autocmds()
    local CREATE_INTERFACE_FILE_COMMAND = "RescriptCreateInterfaceFile"

    vim.api.nvim_create_user_command(CREATE_INTERFACE_FILE_COMMAND, function(opts)
        local implementation_file_path = vim.api.nvim_buf_get_name(0)
        local interface_file_path = implementation_file_path .. "i"

        local backup_file_path

        if vim.fn.filereadable(interface_file_path) == 1 then
            if not opts.bang then
                vim.notify(
                    "Interface file already exists. Use :" .. CREATE_INTERFACE_FILE_COMMAND .. "! to overwrite it.",
                    vim.log.levels.ERROR
                )
                return
            else
                backup_file_path = interface_file_path .. ".backup"
                os.rename(interface_file_path, backup_file_path)
            end
        end

        vim.lsp.buf_request(
            0,
            "textDocument/createInterface",
            { uri = "file://" .. implementation_file_path },
            function()
                local message = "Interface file created"
                if backup_file_path ~= nil then
                    message = message .. ". Backup of existing interface file created at " .. backup_file_path .. "."
                end
                vim.notify(message, vim.log.levels.INFO)
            end
        )
    end, { bang = true })
end

return NVReScript
