local M = {}
local m = {}

function M.setup()
    local plugin = require "lualine"
    local linemode = require "lualine.utils.mode"
    local palette = require "theme.palette"
    local lsp = require "plugins.lsp.lspconfig"

    local diagnostics = m.diagnostics_component()

    local color = {
        active_text = palette.text,
        incative_text = palette.faded_text,
        inverted_text = palette.bar_bg,
        bg = palette.bar_bg,
        emphasized_bg = palette.lighter_gray,
    }

    local theme = {
        normal = {
            a = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" },
            b = { fg = color.active_text, bg = color.bg },
            c = { fg = color.active_text, bg = color.bg },
        },
        command = { a = { fg = color.inverted_text, bg = palette.yellow, gui = "bold" } },
        insert = { a = { fg = color.inverted_text, bg = palette.green, gui = "bold" } },
        visual = { a = { fg = color.inverted_text, bg = palette.purple, gui = "bold" } },
        terminal = { a = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" } },
        replace = { a = { fg = color.inverted_text, bg = palette.red, gui = "bold" } },
        inactive = {
            a = { fg = color.incative_text, bg = color.bg, gui = "bold" },
            b = { fg = color.incative_text, bg = color.bg },
            c = { fg = color.incative_text, bg = color.bg },
        },
    }

    local project_section = {
        function()
            local fs = require "editor.fs"
            return fs.root { capitalize = true }
        end,
        color = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" },
    }

    local tabs_section = {
        "tabs",
        mode = 1,
        tabs_color = {
            active = { fg = color.active_text, bg = color.emphasized_bg },
            inactive = { fg = color.incative_text, bg = color.bg },
        },
    }

    local mode_section = {
        function()
            local m = linemode.get_mode()
            if m == "NORMAL" then
                return "N"
            elseif m == "VISUAL" then
                return "V"
            elseif m == "SELECT" then
                return "S"
            elseif m == "INSERT" then
                return "I"
            elseif m == "REPLACE" then
                return "R"
            elseif m == "COMMAND" then
                return "C"
            elseif m == "EX" then
                return "X"
            elseif m == "TERMINAL" then
                return "T"
            else
                return m
            end
        end,
    }

    local filename_section = {
        "filename",
        path = 1,
        color = { fg = color.active_text, bg = color.emphasized_bg },
        fmt = function(v, _ctx)
            if m.should_ignore_filetype() then
                return nil
            else
                return v
            end
        end,
    }

    local branch_section = {
        "branch",
        color = { fg = color.active_text, bg = color.bg },
    }

    local diagnostics_section = {
        diagnostics,
        sections = {
            "error",
            "warn",
            "info",
            "hint",
        },
        colors = {
            error = "StatusBarDiagnosticError",
            warn  = "StatusBarDiagnosticWarn",
            info  = "StatusBarDiagnosticInfo",
            hint  = "StatusBarDiagnosticHint",
        },
        symbols = {
            error = lsp.signs.Error .. " ",
            warn = lsp.signs.Warn .. " ",
            info = lsp.signs.Info .. " ",
            hint = lsp.signs.Hint .. " ",
        },
    }

    local searchcount_section = "searchcount"

    local encoding_section = {
        "encoding",
        color = { fg = color.incative_text },
    }

    local filetype_section = {
        "filetype",
        colored = false,
        fmt = function(v, _ctx)
            if m.should_ignore_filetype() then
                return nil
            else
                if v == "markdown" then
                    return "md"
                else
                    return v
                end
            end
        end,
    }

    local progress_section = {
        "progress",
        separator = { left = "" },
        color = { fg = color.active_text, bg = color.emphasized_bg },
    }

    local location_seciton = {
        "location",
        padding = { left = 0, right = 1 },
        color = { fg = color.active_text, bg = color.emphasized_bg },
    }

    plugin.setup {
        options = {
            icons_enabled = true,
            theme = theme,
            component_separators = "",
            section_separators = {
                left = "",
                -- left = "",
                right = "",
            },
            disabled_filetypes = {},
            ignore_focus = {},
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = {
                mode_section,
            },
            lualine_b = {
                filename_section,
                branch_section,
                diagnostics_section,
            },
            lualine_c = {},
            lualine_x = {},
            lualine_y = {
                searchcount_section,
                encoding_section,
                filetype_section,
                progress_section,
            },
            lualine_z = {
                location_seciton,
            },
        },
        tabline = {
            lualine_a = { project_section },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { tabs_section },
        },
    }

    m.ensure_tabline_visibility_mode()
end

function M.keymaps()
    K.map { "<M-s>", "Toggle filename in statusline", m.toggle_filename, mode = { "n", "i", "v" } }
end

function M.show()
    local plugin = require "lualine"

    plugin.hide({ unhide = true })
end

function M.hide()
    local plugin = require "lualine"

    plugin.hide()
    vim.o.laststatus = 0
    vim.o.ruler = false
end

function M.rename_tab(name)
    vim.cmd("LualineRenameTab " .. name)
end

-- Private

function m.toggle_filename()
    local plugin = require "lualine"
    local config = plugin.get_config()

    for _, section in pairs(config.sections) do
        for _, component in ipairs(section) do
            if type(component) == "table" and component[1] == "filename" then
                if component.path == 0 then
                    component.path = 1
                else
                    component.path = 0
                end
            end
        end
    end

    plugin.setup(config)
    m.ensure_tabline_visibility_mode()
end

function m.ensure_tabline_visibility_mode()
    -- Uncomment this if you want to show the tabline only when there are multiple tabs.
    -- This line is required because lualine overrides this setting.
    -- 0: never show tabline
    -- 1: show tabline only when there are multiple tabs
    -- 2: always show tabline
    -- vim.cmd "set showtabline=1"
end

function m.diagnostics_component()
    local diagnostics = require("lualine.components.filename"):extend()

    function diagnostics:init(options)
        diagnostics.super.init(self, options)

        self.diagnostics = {
            sections = options.sections,
            symbols = options.symbols,
            last_results = {},
            highlight_groups = {
                error = self:create_hl(options.colors.error, "error"),
                warn = self:create_hl(options.colors.warn, "warn"),
                info = self:create_hl(options.colors.info, "info"),
                hint = self:create_hl(options.colors.hint, "hint"),
            },
        }
    end

    function diagnostics:update_status()
        local context = {
            BUFFER = "buffer",
            WORKSPACE = "workspace",
        }

        local function count_diagnostics(ctx, severity)
            local bufnr

            if ctx == context.BUFFER then
                bufnr = 0
            elseif ctx == context.WORKSPACE then
                bufnr = nil
            else
                vim.print("Unexpected diagnostics context: " .. ctx)
                return nil
            end

            local total = vim.diagnostic.get(bufnr, { severity = severity })

            return vim.tbl_count(total)
        end

        local function get_diagnostic_results()
            local severity = vim.diagnostic.severity

            local results = {}

            local eb = count_diagnostics(context.BUFFER, severity.ERROR)
            local ew = count_diagnostics(context.WORKSPACE, severity.ERROR)
            if eb > 0 or ew > 0 then results.error = { eb, ew } else results.error = nil end

            local wb = count_diagnostics(context.BUFFER, severity.WARN)
            local ww = count_diagnostics(context.WORKSPACE, severity.WARN)
            if wb > 0 or ww > 0 then results.warn = { wb, ww } else results.warn = nil end

            local ib = count_diagnostics(context.BUFFER, severity.INFO)
            local iw = count_diagnostics(context.WORKSPACE, severity.INFO)
            if ib > 0 or iw > 0 then results.info = { ib, iw } else results.info = nil end

            local hb = count_diagnostics(context.BUFFER, severity.HINT)
            local hw = count_diagnostics(context.WORKSPACE, severity.HINT)
            if hb > 0 or hw > 0 then results.hint = { hb, hw } else results.hint = nil end

            for _, v in pairs(results) do
                if v ~= nil then return results end
            end

            return nil
        end

        local output = { " " }

        local bufnr = vim.api.nvim_get_current_buf()

        local diagnostics_results
        if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
            diagnostics_results = get_diagnostic_results()
            self.diagnostics.last_results[bufnr] = diagnostics_results
        else
            diagnostics_results = self.diagnostics.last_results[bufnr]
        end

        if diagnostics_results == nil then return "" end

        local lualine_utils = require "lualine.utils.utils"

        local colors, backgrounds = {}, {}
        for name, hl in pairs(self.diagnostics.highlight_groups) do
            colors[name] = self:format_hl(hl)
            backgrounds[name] = lualine_utils.extract_highlight_colors(colors[name]:match("%%#(.-)#"), "bg")
        end

        local previous_section, padding

        for _, section in ipairs(self.diagnostics.sections) do
            if diagnostics_results[section] ~= nil then
                padding = previous_section and (backgrounds[previous_section] ~= backgrounds[section]) and " " or ""
                previous_section = section

                local icon = self.diagnostics.symbols[section]
                local buffer_total = diagnostics_results[section][1] ~= 0 and diagnostics_results[section][1] or "-"
                local workspace_total = diagnostics_results[section][2]

                table.insert(output, colors[section] .. padding .. icon .. buffer_total .. "/" .. workspace_total)
            end
        end

        return table.concat(output, " ")
    end

    return diagnostics
end

function m.should_ignore_filetype()
    local ft = vim.bo.filetype

    return
        ft == "alpha"
        or ft == "noice"
        or ft == "lazy"
        or ft == "mason"
        or ft == "neo-tree"
        or ft == "TelescopePrompt"
        or ft == "lazygit"
        or ft == "DiffviewFiles"
        or ft == "spectre_panel"
        or ft == "sagarename"
        or ft == "sagafinder"
        or ft == "saga_codeaction"
end

return M
