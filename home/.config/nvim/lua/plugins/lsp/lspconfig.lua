NVLspConfig = {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("nv-lsp-attach", { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                -- Let's set keymaps first
                local keymaps = NVLsp.keymaps()

                for _, keymap in ipairs(keymaps) do
                    if keymap.mode == nil then
                        log.error("Keymap " .. keymap[1] .. " doesn't have mode set")
                        return
                    end

                    if keymap.has then
                        if client then
                            local has_capability = true
                            for _, capability in ipairs(keymap.has) do
                                if not client:supports_method(capability, event.buf) then
                                    has_capability = false
                                    break
                                end
                            end
                            if not has_capability then
                                goto continue
                            end
                        end
                        keymap.has = nil
                    end

                    keymap.buffer = event.buf

                    K.map(keymap)

                    ::continue::
                end

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                if
                    client
                    and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
                then
                    local highlight_augroup = vim.api.nvim_create_augroup("nv-lsp-highlight", { clear = false })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("nv-lsp-detach", { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "nv-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                -- Auto-format on save
                vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                    buffer = event.buf,
                    callback = function()
                        if vim.b.autoformat ~= false then
                            NVConform.format(event.buf)
                        end
                    end,
                })
            end,
        })

        -- Disable autoformatting for specific file types
        vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = {
                "sh",
                "json",
                "jsonc",
                "toml",
                "yaml",
                "clojure",
                "markdown",
            },
            callback = function()
                vim.b.autoformat = false
            end,
        })

        -- Diagnostic Config
        -- See :help vim.diagnostic.Opts
        vim.diagnostic.config({
            severity_sort = true,
            update_in_insert = true,
            float = { border = "rounded", source = "if_many" },
            underline = { severity = vim.diagnostic.severity.WARN },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = NVIcons.error,
                    [vim.diagnostic.severity.WARN] = NVIcons.warn,
                    [vim.diagnostic.severity.INFO] = NVIcons.info,
                    [vim.diagnostic.severity.HINT] = NVIcons.hint,
                },
            },
            virtual_text = {
                source = "if_many",
                spacing = 2,
                format = function(diagnostic)
                    local diagnostic_message = {
                        [vim.diagnostic.severity.ERROR] = diagnostic.message,
                        [vim.diagnostic.severity.WARN] = diagnostic.message,
                        [vim.diagnostic.severity.INFO] = diagnostic.message,
                        [vim.diagnostic.severity.HINT] = diagnostic.message,
                    }
                    return diagnostic_message[diagnostic.severity]
                end,
            },
        })

        require("mason-tool-installer").setup({ ensure_installed = opts.ensure_installed })

        require("mason-lspconfig").setup({
            ensure_installed = {}, -- explicitly set to an empty table as it is handled by mason-tool-installer
            automatic_installation = false,
        })

        -- Setup servers with custom configurations
        local servers = opts.servers or {}
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        for server_name, server_config in pairs(servers) do
            local config = vim.tbl_deep_extend("force", { capabilities = capabilities }, server_config or {})
            require("lspconfig")[server_name].setup(config)
        end
    end,
}

return { NVLspConfig }
