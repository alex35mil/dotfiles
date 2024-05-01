local M = {}
local m = {}

function M.setup()
    local mason = require "mason"
    local config = require "mason-lspconfig"

    mason.setup {
        ui = {
            border = "rounded",
        },
    }

    config.setup {
        -- NOTE: rust is handled by the `rust-tools`
        ensure_installed = {
            "bashls",
            "cssls",
            "dockerls",
            "docker_compose_language_service",
            "html",
            "jsonls",
            "lua_ls",
            "marksman",
            "nil_ls", -- nix
            -- "ocamllsp", -- FIXME: Ocaml LSP is broken
            "reason_ls",
            "rescriptls",
            "sqlls",
            "tailwindcss",
            "tsserver",
            "yamlls",
        },
    }
end

function M.keymaps()
    K.mapseq { "<D-p>l", "LSP: Open package manager", "<Cmd>Mason<CR>", mode = "n" }
end

function M.ensure_hidden()
    if m.is_active() then
        m.close()
        return true
    else
        return false
    end
end

-- Private

function m.is_active()
    return vim.bo.filetype == "mason"
end

function m.close()
    local keys = require "editor.keys"
    keys.send("q", { mode = "x" })
end

return M
