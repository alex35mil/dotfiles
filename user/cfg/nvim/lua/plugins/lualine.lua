local M = {}

local function diagnostics_component()
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

                table.insert(output, colors[section] .. padding .. icon .. buffer_total .. "" .. workspace_total)
            end
        end

        return table.concat(output, " ")
    end

    return diagnostics
end

local function should_ignore_filetype()
    local ft = vim.bo.filetype

    return
        ft == "lazy"
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

function M.setup()
    local plugin = require "lualine"
    local linemode = require "lualine.utils.mode"
    local color = require "theme.palette"
    local lsp = require "utils.lsp"

    local diagnostics = diagnostics_component()

    local theme = {
        normal = {
            a = { fg = color.bg, bg = color.cyan, gui = "bold" },
            b = { fg = color.text, bg = color.darker_gray },
            c = { fg = color.text, bg = color.darker_gray },
        },
        command = { a = { fg = color.bg, bg = color.yellow, gui = "bold" } },
        insert = { a = { fg = color.bg, bg = color.green, gui = "bold" } },
        visual = { a = { fg = color.bg, bg = color.purple, gui = "bold" } },
        terminal = { a = { fg = color.bg, bg = color.cyan, gui = "bold" } },
        replace = { a = { fg = color.bg, bg = color.red, gui = "bold" } },
        inactive = {
            a = { fg = color.faded_text, bg = color.darker_gray, gui = "bold" },
            b = { fg = color.faded_text, bg = color.darker_gray },
            c = { fg = color.faded_text, bg = color.darker_gray },
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
        path = 0,
        color = { fg = color.text, bg = color.lighter_gray },
        fmt = function(v, _ctx)
            if should_ignore_filetype() then
                return nil
            else
                return v
            end
        end,
    }

    local branch_section = {
        "branch",
        color = { fg = color.text, bg = color.darker_gray },
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
        color = { fg = color.faded_text },
    }

    local filetype_section = {
        "filetype",
        colored = false,
        fmt = function(v, _ctx)
            if should_ignore_filetype() then
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
        color = { fg = color.text, bg = color.lighter_gray },
    }

    local location_seciton = {
        "location",
        padding = { left = 0, right = 1 },
        color = { fg = color.text, bg = color.lighter_gray },
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
            }
        },
        tabline = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { { "tabs", mode = 1 } },
        },
    }

    -- lualine overrides this
    vim.cmd "set showtabline=1"
end

return M
