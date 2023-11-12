local M = {}
local m = {}

function M.setup(config)
    config.rescriptls.setup {}

    vim.api.nvim_create_user_command(
        "RescriptCreateInterfaceFile",
        function(opts)
            m.create_interface_file({ force = opts.bang })
        end,
        { bang = true }
    )
end

-- Private

function m.create_interface_file(opts)
    local implementation_file_path = vim.api.nvim_buf_get_name(0)
    local interface_file_path = implementation_file_path .. "i"

    local backup_file_path

    if vim.fn.filereadable(interface_file_path) == 1 then
        if not opts.force then
            vim.api.nvim_err_writeln("Interface file already exists. Use :RescriptCreateInterfaceFile! to overwrite it.")
            return
        else
            -- Create a backup of the existing file
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
            print(message)
        end
    )
end

return M
