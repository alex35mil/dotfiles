local Theme = {}
local Sections = {}

local fn = {}

local __center__ = "%="

NVLualine = {
    "nvim-lualine/lualine.nvim",
    opts = function()
        -- PERF: we don't need this lualine require madness 🤷
        local lualine_require = require("lualine_require")
        lualine_require.require = require

        vim.o.laststatus = vim.g.lualine_laststatus

        return {
            options = {
                theme = Theme.build(),
                section_separators = Theme.no_separators(),
                component_separators = Theme.no_separators(),
                icons_enabled = true,
                disabled_filetypes = { "ministarter" },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = vim.o.laststatus == 3,
            },
            tabline = {
                lualine_a = { Sections.project() },
                lualine_b = {},
                lualine_c = {
                    __center__,
                    Sections.symbol(),
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = { Sections.tabs() },
            },
            sections = {
                lualine_a = {
                    Sections.mode(),
                },
                lualine_b = {
                    Sections.branch(),
                    LazyVim.lualine.pretty_path(), -- FIXME: Respect ignored filytypes
                },
                lualine_c = {
                    __center__,
                    Sections.diagnostics({ icons = true, color = false }),
                },
                lualine_x = {
                    Sections.lsp_progress(),
                    Sections.updates(),
                },
                lualine_y = {
                    Sections.searchcount(),
                    Sections.progress(),
                    Sections.location(),
                    Sections.filetype(),
                },
                lualine_z = {
                    Sections.time(),
                },
            },
        }
    end,
}

local palette = require("theme").palette

local color = {
    active_text = palette.bar_text,
    incative_text = palette.bar_faded_text,
    inverted_text = palette.bar_bg,
    bg = palette.bar_bg,
    emphasized_bg = palette.lighter_gray,
}

function Theme.build()
    return {
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
end

function Theme.no_separators()
    return { left = "", right = "" }
end

function Sections.project()
    return {
        function()
            return NVFS.root({ capitalize = true })
        end,
        color = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" },
    }
end

function Sections.tabs()
    return {
        "tabs",
        mode = 1,
        tabs_color = {
            active = { fg = color.active_text, bg = color.emphasized_bg },
            inactive = { fg = color.incative_text, bg = color.bg },
        },
    }
end

function Sections.mode()
    return {
        function()
            local linemode = require("lualine.utils.mode")

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
end

function Sections.filename()
    return {
        "filename",
        path = 0,
        color = { fg = color.active_text, bg = color.bg },
        fmt = function(v)
            if fn.should_ignore_filetype() then
                return nil
            else
                return v
            end
        end,
    }
end

function Sections.branch()
    return {
        "branch",
        color = { fg = color.active_text, bg = color.emphasized_bg },
    }
end

function Sections.symbol()
    local trouble = require("trouble")

    local symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon:StatusBarSegmentFaded}{symbol.name:StatusBarSegmentFaded} ",
        hl_group = "StatusBarSegmentFaded",
    })

    return {
        symbols and symbols.get,
        cond = function()
            return vim.b.trouble_lualine ~= false and symbols.has()
        end,
    }
end

function Sections.lsp_progress()
    return {
        function()
            return require("noice").api.status.lsp_progress.get_hl() ---@diagnostic disable-line: undefined-field
        end,
        cond = function()
            return fn.is_lsp_progress()
        end,
    }
end

---@param options {icons: boolean, color: boolean}
function Sections.diagnostics(options)
    local icons = LazyVim.config.icons

    local diagnostics = require("lualine.components.filename"):extend()

    function diagnostics:init(opts)
        diagnostics.super.init(self, opts)

        self.diagnostics = {
            sections = opts.sections,
            symbols = opts.symbols,
            last_results = {},
            highlight_groups = {
                error = self:create_hl(opts.colors.error, "error"),
                warn = self:create_hl(opts.colors.warn, "warn"),
                info = self:create_hl(opts.colors.info, "info"),
                hint = self:create_hl(opts.colors.hint, "hint"),
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

        local function get_diagnostic_results(opts)
            opts = vim.tbl_extend("keep", opts or {}, {
                error = true,
                warn = true,
                info = false,
                hint = false,
            })

            local severity = vim.diagnostic.severity

            local results = {}

            if opts.error then
                local eb = count_diagnostics(context.BUFFER, severity.ERROR)
                local ew = count_diagnostics(context.WORKSPACE, severity.ERROR)
                if eb > 0 or ew > 0 then
                    results.error = { eb, ew }
                else
                    results.error = nil
                end
            else
                results.error = nil
            end

            if opts.warn then
                local wb = count_diagnostics(context.BUFFER, severity.WARN)
                local ww = count_diagnostics(context.WORKSPACE, severity.WARN)
                if wb > 0 or ww > 0 then
                    results.warn = { wb, ww }
                else
                    results.warn = nil
                end
            else
                results.warn = nil
            end

            if opts.info then
                local ib = count_diagnostics(context.BUFFER, severity.INFO)
                local iw = count_diagnostics(context.WORKSPACE, severity.INFO)
                if ib > 0 or iw > 0 then
                    results.info = { ib, iw }
                else
                    results.info = nil
                end
            else
                results.info = nil
            end

            if opts.hint then
                local hb = count_diagnostics(context.BUFFER, severity.HINT)
                local hw = count_diagnostics(context.WORKSPACE, severity.HINT)
                if hb > 0 or hw > 0 then
                    results.hint = { hb, hw }
                else
                    results.hint = nil
                end
            else
                results.hint = nil
            end

            for _, v in pairs(results) do
                if v ~= nil then
                    return results
                end
            end

            return nil
        end

        local bufnr = vim.api.nvim_get_current_buf()

        local diagnostics_results
        if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
            diagnostics_results = get_diagnostic_results()
            self.diagnostics.last_results[bufnr] = diagnostics_results
        else
            diagnostics_results = self.diagnostics.last_results[bufnr]
        end

        if diagnostics_results == nil then
            return ""
        end

        local lualine_utils = require("lualine.utils.utils")

        local colors, backgrounds = {}, {}
        for name, hl in pairs(self.diagnostics.highlight_groups) do
            colors[name] = self:format_hl(hl)
            backgrounds[name] = lualine_utils.extract_highlight_colors(colors[name]:match("%%#(.-)#"), "bg")
        end

        local output = {}

        local previous_section, padding

        for _, section in ipairs(self.diagnostics.sections) do
            if diagnostics_results[section] ~= nil then
                padding = previous_section and (backgrounds[previous_section] ~= backgrounds[section]) and " " or ""
                previous_section = section

                local buffer_total = diagnostics_results[section][1] ~= 0 and diagnostics_results[section][1] or "-"
                local workspace_total = diagnostics_results[section][2]

                local segment

                if options.color then
                    segment = colors[section] .. padding
                else
                    segment = padding
                end

                if options.icons then
                    local icon = self.diagnostics.symbols[section]
                    segment = segment .. icon
                end

                segment = segment .. buffer_total .. "/" .. workspace_total .. " "

                table.insert(output, segment)
            end
        end

        if #output > 0 then
            output[#output] = output[#output]:sub(1, -2)
        end

        return table.concat(output, " ")
    end

    return {
        diagnostics,
        sections = {
            "error",
            "warn",
            "info",
            "hint",
        },
        color = { fg = color.incative_text },
        colors = {
            error = "StatusBarDiagnosticError",
            warn = "StatusBarDiagnosticWarn",
            info = "StatusBarDiagnosticInfo",
            hint = "StatusBarDiagnosticHint",
        },
        symbols = {
            error = icons.diagnostics.Error .. " ",
            warn = icons.diagnostics.Warn .. " ",
            info = icons.diagnostics.Info .. " ",
            hint = icons.diagnostics.Hint .. " ",
        },
        cond = function()
            return not fn.is_lsp_progress()
        end,
    }
end

function Sections.updates()
    local status = require("lazy.status")

    return {
        status.updates,
        cond = status.has_updates,
        color = { fg = color.active_text },
    }
end

function Sections.searchcount()
    return "searchcount"
end

function Sections.filetype()
    return {
        "filetype",
        colored = false,
        color = { fg = color.active_text, bg = color.emphasized_bg },
        fmt = function(v, _ctx)
            if fn.should_ignore_filetype() then
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
end

function Sections.progress()
    return {
        "progress",
        separator = " ",
        padding = { left = 1, right = 0 },
    }
end

function Sections.location()
    return {
        "location",
        padding = { left = 0, right = 1 },
    }
end

function Sections.time()
    return {
        function()
            return " " .. os.date("%R")
        end,
        color = function()
            local hour = tonumber(os.date("%H"))

            local bg

            if hour >= 9 and hour < 11 then
                bg = palette.yellow
            elseif hour >= 11 and hour < 18 then
                bg = palette.cyan
            elseif hour >= 18 and hour < 21 then
                bg = palette.orange
            else
                bg = palette.red
            end

            return { fg = color.inverted_text, bg = bg, gui = "bold" }
        end,
    }
end

function NVLualine.show_tabline()
    require("lualine").hide({ place = { "tabline" }, unhide = true })
end

function NVLualine.hide_tabline()
    require("lualine").hide({ place = { "tabline" }, unhide = false })
end

function NVLualine.rename_tab(name)
    vim.cmd("LualineRenameTab " .. name)
end

function fn.is_lsp_progress()
    return package.loaded["noice"] and require("noice").api.status.lsp_progress.has() ---@diagnostic disable-line: undefined-field
end

function fn.should_ignore_filetype()
    local ft = vim.bo.filetype

    return ft == "alpha"
        or ft == "dashboard"
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

return { NVLualine }
