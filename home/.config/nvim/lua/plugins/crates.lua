local M = {}

function M.setup()
    local plugin = require "crates"

    plugin.setup {
        src = {
            cmp = {
                enabled = true,
            },
        },
        popup = {
            keys = {
                hide = { "<Esc>", "<D-w>" },
                open_url = { "<Cr>" },
                select = { "<Cr>" },
                select_alt = { "s" },
                toggle_feature = { "<Cr>" },
                copy_value = { "yy" },
                goto_item = { "gc" },
                jump_forward = { "<C-i>" },
                jump_back = { "<C-o>" },
            },

        },
    }
end

function M.keymaps()
    local plugin = require "crates"

    K.mapseq { "<Leader>cr", "Crates: Reload", plugin.reload, mode = "n" }

    K.mapseq { "<Leader>cv", "Crates: Show versions popup", plugin.show_versions_popup, mode = "n" }
    K.mapseq { "<Leader>cf", "Crates: Show features popup", plugin.show_features_popup, mode = "n" }
    K.mapseq { "<Leader>cd", "Crates: Show dependencies popup", plugin.show_dependencies_popup, mode = "n" }

    K.map { "<C-g>", "Crates: Focus popup", plugin.focus_popup, mode = "n" }

    K.mapseq { "<Leader>cu", "Crates: Upgrade crate", plugin.upgrade_crate, mode = "n" }
    K.mapseq { "<Leader>cu", "Crates: Upgrade selected crates", plugin.upgrade_crates, mode = "v" }
    K.mapseq { "<Leader>ca", "Crates: Upgrade all crates", plugin.upgrade_all_crates, mode = "n" }

    K.mapseq { "<Leader>ce", "Crates: Expand crate to inline table", plugin.expand_plain_crate_to_inline_table, mode = "n" }

    K.mapseq { "<Leader>coh", "Crates: Open homepage", plugin.open_homepage, mode = "n" }
    K.mapseq { "<Leader>cor", "Crates: Open repository", plugin.open_repository, mode = "n" }
    K.mapseq { "<Leader>cod", "Crates: Open documentation", plugin.open_documentation, mode = "n" }
    K.mapseq { "<Leader>coc", "Crates: Open crates.io", plugin.open_crates_io, mode = "n" }
end

return M
