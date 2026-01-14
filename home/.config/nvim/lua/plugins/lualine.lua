local Theme = {}
local Sections = {}

---@class State
---@field tabline "lsp_symbol" | "filepath"
---@field statusline "workspace_lsps" | "buffer_lsps"
local State = {
    tabline = "filepath",
    statusline = "buffer_lsps",
}

local fn = {}

local __center__ = "%="

local palette = NVTheme.palette

local color = {
    active_text = palette.bar_text,
    incative_text = palette.bar_faded_text,
    inverted_text = palette.bar_bg,
    bg = palette.bar_bg,
    emphasized_bg = palette.lighter_gray,
}

NVLualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "folke/noice.nvim",
        "folke/trouble.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    keys = {
        {
            "<C-Del>",
            function()
                fn.toggle_statusline()
            end,
            mode = { "n", "i", "v" },
            desc = "Toggle statusline: Diagnostics from all LSPs or from LSPs attached to the current buffer",
        },
        {
            "<C-BS>",
            function()
                fn.toggle_tabline()
            end,
            mode = { "n", "i", "v" },
            desc = "Toggle tabline: LSP symbol or file path",
        },
    },
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
                    Sections.file_or_lsp_symbol(),
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
                    Sections.window_and_buffer(),
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
        color = function()
            return { fg = color.inverted_text, bg = palette.cyan, gui = "bold" }
        end,
    }
end

function Sections.tabs()
    return {
        "tabs",
        mode = 1,
        tabs_color = {
            active = function()
                return { fg = color.active_text, bg = color.emphasized_bg }
            end,
            inactive = function()
                return { fg = color.incative_text, bg = color.bg }
            end,
        },
    }
end

function Sections.mode()
    local function get_mode_info()
        local linemode = require("lualine.utils.mode")
        local m = linemode.get_mode()

        local mode_config = {
            ["NORMAL"] = { text = "N", bg = palette.cyan },
            ["VISUAL"] = { text = "V", bg = palette.purple },
            ["SELECT"] = { text = "S", bg = palette.purple },
            ["INSERT"] = { text = "I", bg = palette.green },
            ["REPLACE"] = { text = "R", bg = palette.red },
            ["COMMAND"] = { text = "C", bg = palette.yellow },
            ["EX"] = { text = "X", bg = palette.yellow },
            ["TERMINAL"] = { text = "T", bg = palette.orange },
        }

        return mode_config[m] or { text = m, bg = palette.cyan }
    end

    return {
        function()
            return get_mode_info().text
        end,
        color = function()
            local mode_info = get_mode_info()
            return { fg = color.inverted_text, bg = mode_info.bg, gui = "bold" }
        end,
    }
end

function Sections.window_and_buffer()
    return {
        function()
            local tab_icon = "󰬛"
            local win_icon = "󰬞"
            local buf_icon = "󰬉"

            local tabnr = vim.api.nvim_get_current_tabpage()
            local winnr = vim.api.nvim_get_current_win()
            local bufnr = vim.api.nvim_get_current_buf()

            return " " .. tab_icon .. " " .. tabnr .. " " .. win_icon .. " " .. winnr .. " " .. buf_icon .. " " .. bufnr
        end,
        color = function()
            return { fg = color.incative_text, bg = color.bg }
        end,
    }
end

function Sections.branch()
    return {
        "branch",
        color = function()
            return { fg = color.active_text, bg = color.emphasized_bg }
        end,
    }
end

function Sections.file_or_lsp_symbol()
    -- PERF: Lazy initialization
    local __symbols
    local function symbols()
        if not __symbols then
            local trouble = require("trouble")
            __symbols = trouble.statusline({
                mode = "lsp_document_symbols",
                groups = {},
                title = false,
                filter = { range = true },
                format = "{kind_icon:StatusBarSegmentFaded}{symbol.name:StatusBarSegmentFaded} ",
                hl_group = "StatusBarSegmentFaded",
            })
        end
        return __symbols
    end

    return {
        function()
            if State.tabline == "lsp_symbol" then
                return symbols().get()
            else
                local bufname = vim.api.nvim_buf_get_name(0)

                if bufname == "" then
                    return ""
                end

                local relative = NVFS.relative_path(bufname)
                local filename = NVFS.filename(relative)
                local directory = NVFS.dirname(relative)

                if directory == "." then
                    return "%#StatusBarFilename#" .. filename .. "%*"
                else
                    return "%#StatusBarFilename#"
                        .. filename
                        .. "%*%#StatusBarFilenameLoc#"
                        .. " · "
                        .. directory
                        .. "%*"
                end
            end
        end,
        cond = function()
            if State.tabline == "lsp_symbol" then
                return vim.b.trouble_lualine ~= false and symbols().has()
            else
                return true
            end
        end,
        color = function()
            return { fg = color.incative_text, bg = color.bg }
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
            local namespaces

            if ctx == context.BUFFER then
                bufnr = 0
                namespaces = nil
            elseif ctx == context.WORKSPACE then
                bufnr = nil
                if State.statusline == "workspace_lsps" then
                    namespaces = nil
                else
                    -- collect namespaces from LSPs attached to current buffer
                    namespaces = {}
                    local current_buf = vim.api.nvim_get_current_buf()
                    local attached_clients = vim.lsp.get_clients({ bufnr = current_buf })

                    for _, client in ipairs(attached_clients) do
                        local ns = vim.lsp.diagnostic.get_namespace(client.id)
                        table.insert(namespaces, ns)
                    end
                end
            else
                log.error("Unexpected diagnostics context: " .. ctx)
                return nil
            end

            local total_count = 0

            if namespaces then
                for _, ns in ipairs(namespaces) do
                    local reported = vim.diagnostic.get(bufnr, {
                        severity = severity,
                        namespace = ns,
                    })
                    total_count = total_count + vim.tbl_count(reported)
                end
            else
                local reported = vim.diagnostic.get(bufnr, { severity = severity })
                total_count = vim.tbl_count(reported)
            end

            return total_count
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

        local lsp_scope_icon
        local all_clear_icon = "󰓏"

        if State.statusline == "buffer_lsps" then
            local devicons = require("nvim-web-devicons")

            local icon, _ = devicons.get_icon(vim.fn.expand("%:t"))
            if icon == nil then
                icon, _ = devicons.get_icon_by_filetype(vim.bo.filetype)
            end

            if icon then
                lsp_scope_icon = icon .. "    "
            end
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
            return lsp_scope_icon and lsp_scope_icon .. all_clear_icon or all_clear_icon
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

        local result = table.concat(output, " ")

        return lsp_scope_icon and lsp_scope_icon .. result or result
    end

    return {
        diagnostics,
        sections = {
            "error",
            "warn",
            "info",
            "hint",
        },
        color = function()
            return { fg = color.incative_text, bg = color.bg }
        end,
        colors = {
            error = "StatusBarDiagnosticError",
            warn = "StatusBarDiagnosticWarn",
            info = "StatusBarDiagnosticInfo",
            hint = "StatusBarDiagnosticHint",
        },
        symbols = {
            error = NVIcons.error .. " ",
            warn = NVIcons.warn .. " ",
            info = NVIcons.info .. " ",
            hint = NVIcons.hint .. " ",
        },
        cond = function()
            return fn.has_lsp_attached() and not fn.is_lsp_progress()
        end,
    }
end

function Sections.updates()
    local status = require("lazy.status")

    return {
        status.updates,
        cond = status.has_updates,
        color = function()
            return { fg = color.incative_text, bg = color.bg }
        end,
    }
end

function Sections.searchcount()
    return {
        "searchcount",
        color = function()
            return { fg = color.incative_text, bg = color.bg }
        end,
    }
end

function Sections.filetype()
    return {
        "filetype",
        colored = false,
        color = function()
            return { fg = color.active_text, bg = color.emphasized_bg }
        end,
        fmt = function(v, _ctx)
            if fn.should_ignore_filetype() then
                return nil
            else
                if v == "markdown" then
                    return "md"
                elseif v == "snacks_terminal" then
                    return "term"
                elseif v == "snacks_picker_input" then
                    return "picker"
                elseif v == "snacks_picker_list" then
                    return "finder"
                elseif v == "snacks_picker_preview" then
                    return "preview"
                elseif v == "lazy" then
                    return "plugins"
                elseif v == "mason" then
                    return "tools"
                elseif v == "grug-far" then
                    return "search"
                elseif v == "DiffviewFiles" then
                    return "diff"
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
        padding = { left = 1, right = 1 },
        color = function()
            return { fg = color.incative_text, bg = color.bg }
        end,
    }
end

function Sections.location()
    return {
        "location",
        padding = { left = 0, right = 1 },
        color = function()
            return { fg = color.incative_text, bg = color.bg }
        end,
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

function NVLualine.show_everything()
    vim.o.laststatus = 3
    vim.o.showtabline = 2
end

function NVLualine.hide_everything()
    vim.o.laststatus = 0
    vim.o.showtabline = 0
end

function NVLualine.show_tabline()
    require("lualine").hide({ place = { "tabline" }, unhide = true })
end

function NVLualine.hide_tabline()
    require("lualine").hide({ place = { "tabline" }, unhide = false })
end

function NVLualine.rename_tab(icon, name)
    vim.cmd("LualineRenameTab " .. icon .. " " .. name)
end

function fn.toggle_tabline()
    if State.tabline == "lsp_symbol" then
        State.tabline = "filepath"
    else
        State.tabline = "lsp_symbol"
    end
    require("lualine").refresh({ place = { "tabline" } })
end

function fn.toggle_statusline()
    if State.statusline == "workspace_lsps" then
        State.statusline = "buffer_lsps"
    else
        State.statusline = "workspace_lsps"
    end
    require("lualine").refresh({ place = { "statusline" } })
end

function fn.has_lsp_attached()
    return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end

function fn.is_lsp_progress()
    return package.loaded["noice"] and require("noice").api.status.lsp_progress.has() ---@diagnostic disable-line: undefined-field
end

function fn.should_ignore_filetype()
    local ft = vim.bo.filetype
    return ft == "noice"
end

return { NVLualine }
