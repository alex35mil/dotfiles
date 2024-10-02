NVLsp = {}

---@class Popup
---@field type PopupType
---@field popup NuiPopup
---@field parent WinID
---@field layout PopupLayout
local Popup = Class()

---@class HoverPopup: Popup
---@field type "hover"
---@field popup NuiPopup
---@field message NoiceMessage
---@field new fun(self, parent: WinID, bounding_box: BoundingBox, message: NoiceMessage): DiagnosticPopup
local HoverPopup = Class(Popup)

---@class DiagnosticPopup: Popup
---@field type "diagnostic"
---@field popup NuiPopup
---@field diagnostics Diagnostic[]
---@field new fun(self, parent: WinID, bounding_box: BoundingBox, diagnostics: Diagnostic[]): DiagnosticPopup
local DiagnosticPopup = Class(Popup)

local ERROR = vim.diagnostic.severity.ERROR
local WARN = vim.diagnostic.severity.WARN
local INFO = vim.diagnostic.severity.INFO
local HINT = vim.diagnostic.severity.HINT

function NVLsp.keymaps()
    K.map({
        "<D-i>",
        "LSP: Show hover doc",
        HoverPopup.show,
        mode = { "n", "i" },
    })
    K.map({
        "<D-S-i>",
        "LSP: Show diagnostics under cursor",
        DiagnosticPopup.show_current,
        mode = { "n", "i" },
    })
    K.map({
        "<D-S-h>",
        "LSP: Jump to next error",
        function()
            DiagnosticPopup.show_next(ERROR)
        end,
        mode = { "n", "i" },
    })
    K.map({
        "<D-S-t>",
        "LSP: Jump to previous error",
        function()
            DiagnosticPopup.show_previous(ERROR)
        end,
        mode = { "n", "i" },
    })
    K.map({
        "<C-S-h>",
        "LSP: Jump to next warning",
        function()
            DiagnosticPopup.show_next(WARN)
        end,
        mode = { "n", "i" },
    })
    K.map({
        "<C-S-t>",
        "LSP: Jump to previous warning",
        function()
            DiagnosticPopup.show_previous(WARN)
        end,
        mode = { "n", "i" },
    })
end

--- Config ---

---@class Config
---@field win WinConfig
---@field diagnostic DiagnosticConfig

---@class WinConfig
---@field max_width integer?
---@field max_height integer?
---@field border BorderConfig

---@class BorderConfig
---@field style nui_popup_border_option_style?
---@field text nui_popup_border_option_text?
---@field padding nui_popup_border_option_padding

---@class DiagnosticConfig
---@field severity table<vim.diagnostic.Severity, SeverityConfig>

---@alias SeverityConfig {label: string, hl: {label: string, message: string}}

---@type Config
local config = {
    win = {
        max_width = nil,
        max_height = nil,
        border = {
            style = "none",
            padding = { top = 1, bottom = 1, left = 3, right = 3 },
        },
    },
    diagnostic = {
        severity = {
            [ERROR] = { label = "E", hl = { label = "DiagnosticFloatingErrorLabel", message = "DiagnosticError" } },
            [WARN] = { label = "W", hl = { label = "DiagnosticFloatingWarnLabel", message = "DiagnosticWarn" } },
            [INFO] = { label = "I", hl = { label = "DiagnosticFloatingInfoLabel", message = "DiagnosticInfo" } },
            [HINT] = { label = "H", hl = { label = "DiagnosticFloatingHintLabel", message = "DiagnosticHint" } },
        },
    },
}

--- Types ---

---@alias BufID integer
---@alias WinID integer

---@enum PopupType
local POPUP_TYPE = {
    hover = 1,
    diagnostic = 2,
}

---@class PopupLayout
---@field size nui_layout_option_size
---@field relative nui_layout_option_relative_type
---@field position nui_layout_option_position

---@class BoundingBox
---@field w integer
---@field h integer

--- Popups Store ---

---@class Popups
---@field [WinID] HoverPopup | DiagnosticPopup
local Popups = {}

---@param winid WinID
---@return (HoverPopup | DiagnosticPopup)?
function Popups:get_popup(winid)
    return self[winid]
end

---@param winid WinID
---@return HoverPopup?
function Popups:get_hover_popup(winid)
    local popup = self[winid]

    if popup and popup.type == POPUP_TYPE.hover then
        ---@cast popup HoverPopup
        return popup
    end
end

---@param winid WinID
---@return DiagnosticPopup?
function Popups:get_diagnoscic_popup(winid)
    local popup = self[winid]

    if popup and popup.type == POPUP_TYPE.diagnostic then
        ---@cast popup DiagnosticPopup
        return popup
    end
end

---@param winid WinID
function Popups:ensure_unmounted(winid)
    local popup = self[winid]

    if popup then
        popup:unmount()
    end
end

--- Popup ---

---@class PopupInitOpts
---@field type PopupType
---@field parent WinID
---@field bounding_box BoundingBox

---@param opts PopupInitOpts
function Popup:init(opts)
    local NuiPopup = require("nui.popup")

    local win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(0)

    local editor_height = vim.o.lines - vim.o.cmdheight
    local cursor_screen_row = vim.fn.screenpos(win, cursor[1], 1).row
    local space_above = cursor_screen_row - 1
    local space_below = editor_height - cursor_screen_row
    local v_space = math.max(space_above, space_below) - config.win.border.padding.top - config.win.border.padding.bottom

    local total_width = vim.o.columns
    local cursor_screen_pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
    local h_space = total_width - cursor_screen_pos.col - config.win.border.padding.left - config.win.border.padding.right

    local width = math.min(h_space, opts.bounding_box.w)
    if config.win.max_width ~= nil then
        width = math.min(width, config.win.max_width)
    end

    local height = math.min(v_space, opts.bounding_box.h)
    if config.win.max_height ~= nil then
        height = math.min(height, config.win.max_height)
    end

    local row
    if space_above > space_below then
        row = -height - 1
    else
        row = 2
    end

    local relative = "cursor"
    local position = { row = row, col = 0 }
    local size = { width = width, height = height }
    local border = {
        style = config.win.border.style,
        text = config.win.border.text,
        padding = config.win.border.padding,
    }

    local popup = NuiPopup({
        enter = false,
        focusable = true,
        border = border,
        relative = relative,
        position = position,
        size = size,
    })

    self.type = opts.type
    self.popup = popup
    self.parent = opts.parent
    self.layout = {
        size = size,
        relative = relative,
        position = position,
    }
end

Popup.PARENT_WINID_KEY = "__LSP_POPUP_PARENT_WINID"

function Popup:set_lsp_popup_parent_winid()
    vim.api.nvim_win_set_var(self.popup.winid, Popup.PARENT_WINID_KEY, self.parent)
end

---@return WinID?
function Popup.get_lsp_popup_parent_winid()
    local success, parent_win = pcall(vim.api.nvim_win_get_var, 0, Popup.PARENT_WINID_KEY)
    return success and parent_win or nil
end

function Popup:store_meta()
    ---@cast self HoverPopup | DiagnosticPopup
    Popups[self.parent] = self
    self:set_lsp_popup_parent_winid()
end

function Popup:attach_listeners()
    local popup = self.popup

    local augroup_id = vim.api.nvim_create_augroup("LSPPopupGroup", { clear = true })

    local function unmount()
        local current_bufid = vim.api.nvim_get_current_buf()

        if current_bufid ~= popup.bufnr then
            self:unmount()
            vim.api.nvim_del_augroup_by_id(augroup_id)
        end
    end

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
        group = augroup_id,
        callback = unmount,
        once = true,
    })

    vim.api.nvim_create_autocmd({ "WinScrolled" }, {
        group = augroup_id,
        buffer = vim.api.nvim_get_current_buf(),
        callback = function()
            local layout = self.layout

            popup:update_layout({
                relative = layout.relative,
                position = layout.position,
            })
        end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = augroup_id,
        pattern = tostring(popup.winid),
        callback = unmount,
        once = true,
    })
end

---@return WinID
function Popup:winid()
    return self.popup.winid
end

function Popup:focus()
    vim.api.nvim_set_current_win(self.popup.winid)
end

function Popup:unmount()
    self.popup:unmount()
    Popups[self.parent] = nil
end

--- DiagnosticPopup ---

---@param parent WinID
---@param bounding_box BoundingBox
---@param diagnostics Diagnostic[]
function DiagnosticPopup:init(parent, bounding_box, diagnostics)
    Popup.init(self, { type = POPUP_TYPE.diagnostic, parent = parent, bounding_box = bounding_box })
    self.diagnostics = diagnostics
end

function DiagnosticPopup:render()
    local popup = self.popup

    popup:mount()

    local current_line = 0

    for _, diagnostic in ipairs(self.diagnostics) do
        local label = diagnostic.label
        local message = diagnostic.message or {}

        -- Insert the text into the buffer
        vim.api.nvim_buf_set_lines(popup.bufnr, current_line, current_line + #message.lines, false, message.lines)

        -- Apply main highlight to the entire text block
        vim.api.nvim_buf_set_extmark(popup.bufnr, popup.ns_id, current_line, 0, {
            end_line = current_line + #message.lines,
            end_col = 0,
            hl_group = message.hl,
        })

        -- Add label as a virtual text
        local label_block = " " .. label.text .. " "

        vim.api.nvim_buf_set_extmark(popup.bufnr, popup.ns_id, current_line, 0, {
            virt_text = { { label_block, label.hl }, { " ", nil } },
            virt_text_pos = "inline",
            hl_mode = "replace",
        })

        -- Pad subsequent lines for alignment
        if #message.lines > 1 then
            for i = 1, #message.lines - 1 do
                vim.api.nvim_buf_set_extmark(popup.bufnr, popup.ns_id, current_line + i, 0, {
                    virt_text = { { string.rep(" ", vim.fn.strdisplaywidth(label_block) + 1), nil } },
                    virt_text_pos = "inline",
                    hl_mode = "replace",
                })
            end
        end

        current_line = current_line + #message.lines
    end

    self:store_meta()
    self:attach_listeners()
end

---@alias DiagnosticJumpTarget "next"| "previous"
---@alias DiagnosticPopupTarget "current" | DiagnosticJumpTarget

function DiagnosticPopup.show_current()
    DiagnosticPopup.show({ target = "current" })
end

---@param severity vim.diagnostic.Severity?
function DiagnosticPopup.show_next(severity)
    DiagnosticPopup.show({ target = "next", severity = severity })
end

---@param severity vim.diagnostic.Severity?
function DiagnosticPopup.show_previous(severity)
    DiagnosticPopup.show({ target = "previous", severity = severity })
end

---@param opts {target: DiagnosticPopupTarget, severity: vim.diagnostic.Severity?}
function DiagnosticPopup.show(opts)
    local current_winid = vim.api.nvim_get_current_win()

    local shown_popup = Popups:get_diagnoscic_popup(current_winid)

    -- If there's already opened popup of this type - just focus it
    if opts.target == "current" and shown_popup then
        shown_popup:focus()
        return
    end

    -- Unmounting whatever mounted
    Popups:ensure_unmounted(current_winid)

    -- If the cursor is off-target, jump to the target first
    if opts.target == "next" or opts.target == "previous" then
        local jump_target = opts.target

        ---@cast jump_target DiagnosticJumpTarget
        if not DiagnosticPopup.jump({ target = jump_target, severity = opts.severity }) then
            return
        end
    end

    local lsp_diagnostics = DiagnosticPopup.get_diagnoscics_under_cursor()

    if #lsp_diagnostics == 0 then
        return
    end

    local diagnostics = DiagnosticPopup.format_diagnostics(lsp_diagnostics)
    local bounding_box = DiagnosticPopup.get_bounding_box(diagnostics)

    local popup = DiagnosticPopup:new(current_winid, bounding_box, diagnostics)

    vim.schedule(function()
        popup:render()
    end)
end

---@param opts {target: DiagnosticJumpTarget, severity: vim.diagnostic.Severity?}
---@return boolean
function DiagnosticPopup.jump(opts)
    local pos

    local get_pos_opts = {
        severity = opts.severity,
    }

    if opts.target == "next" then
        pos = vim.diagnostic.get_next_pos(get_pos_opts)
    elseif opts.target == "previous" then
        pos = vim.diagnostic.get_prev_pos(get_pos_opts)
    else
        log.error("Unexpected diagnostics target: " .. vim.inspect(opts.target))
        return false
    end

    if not pos then
        if opts.severity then
            log.info("No " .. vim.diagnostic.severity[opts.severity] .. " diagnostics found")
        else
            log.info("No diagnostics found")
        end

        return false
    end

    vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })

    return true
end

---@return vim.Diagnostic[]
function DiagnosticPopup.get_diagnoscics_under_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)

    local line = cursor[1] - 1 -- Convert to 0-indexed
    local col = cursor[2]

    local line_diagnostics = vim.diagnostic.get(0, { lnum = line })

    local diagnostics = {}

    for _, diagnostic in ipairs(line_diagnostics) do
        local end_col
        if diagnostic.end_lnum ~= diagnostic.lnum then
            end_col = vim.fn.col({ diagnostic.lnum, "$" }) - 1
        else
            end_col = diagnostic.end_col
        end

        if diagnostic.col <= col and col < end_col then
            table.insert(diagnostics, diagnostic)
        end
    end

    return diagnostics
end

---@class Diagnostic
---@field label {text: string, hl: string}
---@field message {lines: string[], hl: string}}

---@param diagnostics vim.Diagnostic[]
---@return Diagnostic[]
function DiagnosticPopup.format_diagnostics(diagnostics)
    local result = {}

    for i, diagnostic in ipairs(diagnostics) do
        local severity = config.diagnostic.severity[diagnostic.severity]

        local content

        if
            diagnostic.user_data
            and diagnostic.user_data.lsp
            and diagnostic.user_data.lsp.data
            and diagnostic.user_data.lsp.data.rendered
        then
            content = diagnostic.user_data.lsp.data.rendered
        else
            content = diagnostic.message
        end

        local lines = vim.split(content, "\n")

        while #lines > 0 and lines[1]:match("^%s*$") do
            table.remove(lines, 1)
        end

        while #lines > 0 and lines[#lines]:match("^%s*$") do
            table.remove(lines)
        end

        result[i] = {
            label = {
                text = severity.label,
                hl = severity.hl.label,
            },
            message = {
                lines = lines,
                hl = severity.hl.message,
            },
        }
    end

    return result
end

---@param diagnostics Diagnostic[]
---@return BoundingBox
function DiagnosticPopup.get_bounding_box(diagnostics)
    local max_line_length = 0
    local max_prefix_len = 0
    local total_lines = 0

    for _, diagnostic in ipairs(diagnostics) do
        local lines = diagnostic.message.lines
        for _, line in ipairs(lines) do
            max_line_length = math.max(max_line_length, vim.fn.strdisplaywidth(line))
        end
        max_prefix_len = math.max(max_prefix_len, vim.fn.strdisplaywidth(diagnostic.label.text) + 3) -- 2 spaces around the label and one after
        total_lines = total_lines + #lines
    end

    return {
        w = max_line_length + max_prefix_len,
        h = total_lines,
    }
end

--- HoverPopup ---

---@param parent WinID
---@param bounding_box BoundingBox
---@param message NoiceMessage
function HoverPopup:init(parent, bounding_box, message)
    Popup.init(self, { type = POPUP_TYPE.hover, parent = parent, bounding_box = bounding_box }) -- Initialize NuiPopup as needed
    self.message = message
end

function HoverPopup.show()
    local current_winid = vim.api.nvim_get_current_win()

    local shown_popup = Popups:get_hover_popup(current_winid)

    -- If there's already opened popup of this type - just focus it
    if shown_popup then
        shown_popup:focus()
        return
    end

    -- Unmounting whatever is mounted
    Popups:ensure_unmounted(current_winid)

    local params = vim.lsp.util.make_position_params()

    vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result, ctx, _)
        if not result or not result.contents then
            log.info("No infromation available")
            return
        end

        local message = HoverPopup.format_message(result, ctx)
        local bounding_box = HoverPopup.get_bounding_box(message)

        local popup = HoverPopup:new(current_winid, bounding_box, message)

        vim.schedule(function()
            popup:render()
        end)
    end)
end

---@param result any
---@param ctx lsp.HandlerContext
---@return NoiceMessage
function HoverPopup.format_message(result, ctx)
    local Message = require("noice.message")
    local Format = require("noice.lsp.format")

    local message = Message("lsp", "hover")

    Format.format(message, result.contents, { ft = vim.bo[ctx.bufnr].filetype })

    return message
end

---@param message NoiceMessage
---@return BoundingBox
function HoverPopup.get_bounding_box(message)
    return {
        w = message:width(),
        h = message:height(),
    }
end

function HoverPopup:render()
    local popup = self.popup

    popup:mount()

    self.message:render(popup.bufnr, popup.ns_id)

    self:store_meta()
    self:attach_listeners()
end

--- Exports ---

---@param direction "up"|"down"
function NVLsp.scroll_popup(direction)
    local popup = Popups:get_popup(vim.api.nvim_get_current_win())

    if not popup then
        return false
    end

    local nuice = require("noice.util.nui")

    local winid = popup:winid()

    if direction == "up" then
        nuice.scroll(winid, -4)
        return true
    elseif direction == "down" then
        nuice.scroll(winid, 4)
        return true
    else
        log.error("Unexpected direction: " .. direction)
        return false
    end
end

function NVLsp.ensure_popup_hidden()
    -- Let's check first if we're inside a diagnostic popup
    local parent_winid = Popup.get_lsp_popup_parent_winid()

    if parent_winid then
        local popup = Popups:get_popup(parent_winid)

        if popup then
            popup:unmount()
        else
            log.warn("Popup parent ID is set, but it's not found in the state")
        end

        return true
    else
        local current_winid = vim.api.nvim_get_current_win()

        local popup = Popups:get_popup(current_winid)

        if not popup then
            return false
        end

        popup:unmount()

        return true
    end
end
