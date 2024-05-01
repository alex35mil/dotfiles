local M = {}
local m = {}

function M.setup()
    local plugin = require "spectre"
    local editor = require "editor.searchreplace"

    local search = editor.search
    local replace = editor.replace

    plugin.setup {
        default = {
            find = {
                cmd = search.cmd,
                options = {
                    "hidden",
                    "smart-case",
                },
            },
            replace = {
                cmd = replace.cmd,
            },
        },
        find_engine = {
            [search.cmd] = {
                cmd = search.cmd,
                args = search.args,
                options = {
                    ["hidden"] = {
                        value = search.optional_args.with_hidden,
                        desc = "hidden files",
                        icon = "[H]",
                    },
                    ["ignored"] = {
                        value = search.optional_args.with_ignored,
                        desc = "search in ignored files",
                        icon = "[G]",
                    },
                    ["smart-case"] = {
                        value = search.optional_args.smart_case,
                        icon = "[S]",
                        desc = "smart case",
                    },
                    ["ignore-case"] = {
                        value = search.optional_args.ignore_case,
                        icon = "[I]",
                        desc = "ignore case",
                    },
                },
            },
        },
        replace_engine = {
            [editor.replace.cmd] = {
                cmd = editor.replace.cmd,
                args = editor.replace.args,
            },
        },

    }
end

function M.keymaps()
    K.mapseq { "<D-S>", "Open search in project", m.open_project_search, mode = "n" }
    K.mapseq { "<Leader>sc", "Open search in current buffer", m.open_current_buffer_search, mode = "n" }
    K.mapseq { "<Leader>swg", "Search current word in project", m.search_word_in_project, mode = "n" }
    K.mapseq { "<Leader>swc", "Search current word in current buffer", m.search_word_in_current_buffer, mode = "n" }
end

function M.ensure_active_closed()
    if m.is_active() then
        m.close()
        return true
    else
        return false
    end
end

function M.ensure_any_closed()
    local state = require "spectre.state"
    if state.bufnr ~= nil then
        m.close()
        return true
    else
        return false
    end
end

-- Private

function m.open(params)
    local spectre = require "spectre"
    local zenmode = require "plugins.zen-mode"

    zenmode.ensure_deacitvated()

    if params.current_buffer then
        spectre.open_file_search { select_word = params.select_word }
    else
        if params.select_word then
            spectre.open_visual({ select_word = params.select_word })
        else
            spectre.open { select_word = params.select_word }
        end
    end
end

function m.open_project_search()
    m.open { select_word = false }
end

function m.search_word_in_project()
    m.open { select_word = true }
end

function m.open_current_buffer_search()
    m.open { current_buffer = true, select_word = false }
end

function m.search_word_in_current_buffer()
    m.open { current_buffer = true, select_word = true }
end

function m.is_active()
    return vim.bo.filetype == "spectre_panel"
end

function m.close()
    local plugin = require "spectre"
    plugin.close()
end

return M
