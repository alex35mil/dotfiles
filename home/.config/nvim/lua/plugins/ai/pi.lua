local fn = {}

---@alias LimitThresholds { warning: number, error: number }

--- How a rate-limit window's usage is planned. The window is split into equal periods, and
--- usage is colored by how far it runs ahead of the plan through the current period.
---@class LimitPlan
---@field window_seconds integer Window length; it starts `window_seconds` before the reset.
---@field budgets number[] Planned share, in percent, for each period; adds up to 100.
---@field error_margin number Percentage points above the plan where warning turns into error.
---@field final LimitThresholds The last period's plan is 100%, so it colors by what's left instead.
---@field reset_format string `os.date` format of the reset time, shown while colored.

---@type LimitPlan
local FIVE_HOUR_PLAN = {
    window_seconds = 5 * 60 * 60,
    budgets = { 20, 20, 20, 20, 20 },
    error_margin = 10,
    final = { warning = 95, error = 98 },
    reset_format = "%H:%M",
}

--- The week resets on Monday, so periods run Monday to Sunday: less work planned on the weekend.
---@type LimitPlan
local WEEKLY_PLAN = {
    window_seconds = 7 * 24 * 60 * 60,
    budgets = { 16, 16, 16, 16, 16, 10, 10 },
    error_margin = 5,
    final = { warning = 95, error = 98 },
    reset_format = "%a %H:%M",
}

NVPi = {
    main = "pi",
    dir = "/Users/Alex/Projects/personal/tooling/pi.nvim",
    dependencies = {
        "HakonHarnes/img-clip.nvim",
    },
    opts = {
        debug = true,
        expand_startup_details = false,
        models = {
            { match = "claude-opus-5-5", exact = true },
            { match = "gpt-6.1-sol", exact = true },
        },
        process = {
            descriptor = {
                path = ".agents/pi.nvim.json",
                trusted_paths = { "~/Projects/personal/" },
            },
            stop = {
                on_failure = function(report)
                    vim.system({
                        "osascript",
                        "-e",
                        ('display notification %q with title "pi cleanup failed"'):format(report.workspace),
                    }):wait()
                end,
            },
        },
        layout = {
            side = function()
                return {
                    position = "right",
                    width = NVScreen.is_large() and 0.35 or 0.45,
                }
            end,
            float = function()
                local size = NVScreen.is_large() and { width = 0.6, height = 0.85 } or { width = 0.8, height = 0.85 }
                return {
                    width = size.width,
                    height = size.height,
                    border = "rounded",
                }
            end,
        },
        panels = {
            history = {
                name = function(tab_id)
                    return "π  󰫰󰫵󰫮󰬁  " .. tab_id
                end,
            },
            prompt = {
                name = function(tab_id)
                    return "π  󰫽󰫿󰫼󰫺󰫽󰬁  " .. tab_id
                end,
            },
        },
        diff = {
            icons = {
                note = "󰣒",
            },
            keys = {
                accept = { "<C-CR>", modes = { "n", "i", "v" } },
                reject = { NVKeyRemaps["<C-c>"], modes = { "n", "i", "v" } },
                expand_context = { "+", modes = { "n" } },
                shrink_context = { "-", modes = { "n" } },
                edit_note = { "<D-S-n>", modes = { "n", "v" } },
                delete_note = { "<D-S-x>", modes = { "n", "v" } },
                list_notes = "<D-S-l>",
            },
        },
        statusline = {
            icons = "monochrome",
            layout = {
                left = {
                    function(state)
                        local runtime = state.extensions["status:runtime"]
                        if runtime == "sandbox" then
                            return "󰷛", "PiStatusLineIcon"
                        elseif runtime == "host" then
                            return "󰍹", "PiStatusLineWarning"
                        end
                    end,
                    "   ",
                    "context",
                    "   ",
                    function(state)
                        local limit = fn.limit(state, "h5")
                        if limit then
                            local hl = fn.limit_hl(limit, FIVE_HOUR_PLAN)
                            return fn.limit_text("", limit, FIVE_HOUR_PLAN, hl), hl
                        end
                    end,
                    "   ",
                    function(state)
                        local limit = fn.limit(state, "wk")
                        if limit then
                            local hl = fn.limit_hl(limit, WEEKLY_PLAN)
                            return fn.limit_text("󱨴", limit, WEEKLY_PLAN, hl), hl
                        end
                    end,
                    "   ",
                    function(state)
                        local status = state.extensions["permissions"]
                        if not status then
                            return
                        end
                        if status:find("Auto%-accept") then
                            return "󰐌", "PiStatusLineOn"
                        elseif status:find("Review") then
                            return "󰓔", "PiStatusLineWarning"
                        else
                            log.warn("Unexpected π permissions status")
                        end
                    end,
                    "   ",
                    "attention",
                },
                right = { "model", "   ", "thinking" },
            },
        },
        dialog = {
            keys = {
                confirm = { { "<C-CR>", modes = { "n", "i" } } },
                cancel = { { NVKeymaps.close, modes = { "n", "i" } } },
            },
        },
        zen = {
            keys = {
                toggle = { "<D-f>", modes = { "n", "i", "v" } },
                exit = { NVKeymaps.close, modes = { "n", "i", "i" } },
            },
        },
        on_widget = function(key, lines)
            if key == "rules:load" then
                local content = {}
                for _, line in ipairs(lines) do
                    content[#content + 1] = {
                        { "   ╰  rule: " .. line, "Comment" },
                    }
                end
                return {
                    target = "history",
                    block = "custom",
                    content = content,
                }
            end
            return nil
        end,
    },
    keys = function()
        return {
            {
                "<D-S-c>",
                function()
                    vim.cmd("Pi layout=float")
                end,
                mode = { "n", "i", "v" },
                desc = "Toggle π in a float layout",
            },
            {
                "<D-S-s>",
                function()
                    vim.cmd("Pi layout=side")
                end,
                mode = { "n", "i", "v" },
                desc = "Toggle π in a side layout",
            },
            {
                "<C-S-c>",
                function()
                    vim.cmd("PiContinue layout=float")
                end,
                mode = { "n", "i", "v" },
                desc = "Continue last π session in a float layout",
            },
            {
                "<C-S-s>",
                function()
                    vim.cmd("PiContinue layout=side")
                end,
                mode = { "n", "i", "v" },
                desc = "Continue last π session in a side layout",
            },
            {
                "<M-S-c>",
                function()
                    vim.cmd("PiResume layout=float")
                end,
                mode = { "n", "i", "v" },
                desc = "Select past π session and load it in a float layout",
            },
            {
                "<M-S-s>",
                function()
                    vim.cmd("PiResume layout=side")
                end,
                mode = { "n", "i", "v" },
                desc = "Select past π session and load it in a side layout",
            },
            {
                "<M-c>",
                function()
                    vim.cmd("PiToggleLayout")
                end,
                mode = { "n", "i", "v" },
                desc = "Toggle π layout (side/float)",
            },
            {
                "<D-p>",
                function()
                    vim.cmd("PiSendMention")
                end,
                mode = { "n", "i", "v" },
                desc = "Send @-mention to π and focus the chat",
            },
            {
                "<M-w>", -- what?!
                function()
                    vim.cmd("PiAttention")
                end,
                mode = { "n", "i", "v" },
                desc = "Give an agent a bit of attention",
            },
        }
    end,
}

function NVPi.autocmds()
    local pi = require("pi")

    local group = vim.api.nvim_create_augroup("pi-custom-keybinds", { clear = true })

    local keymap = function(key, event, action)
        vim.keymap.set({ "n", "i", "v" }, key, action, { buffer = event.buf })
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "pi-chat-history", "pi-chat-prompt", "pi-chat-attachments" },
        callback = function(event)
            keymap(NVKeymaps.close, event, function()
                vim.cmd("PiToggleChat")
            end)
            keymap(NVKeyRemaps["<C-c>"], event, function()
                vim.cmd("PiAbort")
            end)
            keymap("<D-S-w>", event, function()
                vim.cmd("PiStop")
            end)
            keymap("<C-o>", event, function()
                pi.toggle_history_blocks()
            end)
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "pi-chat-history" },
        callback = function(event)
            keymap("&", event, function()
                pi.focus_chat_prompt()
                pi.scroll_chat_history_to_bottom()
            end)
            keymap("<S-Down>", event, function()
                pi.focus_chat_prompt()
            end)
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "pi-chat-prompt" },
        callback = function(event)
            keymap("<S-Up>", event, function()
                pi.focus_chat_history()
            end)
            keymap("<S-Down>", event, function()
                pi.focus_chat_attachments()
            end)
            keymap(NVKeymaps.scroll_ctx.up, event, function()
                pi.scroll_chat_history("up", 2)
            end)
            keymap(NVKeymaps.scroll_ctx.down, event, function()
                pi.scroll_chat_history("down", 2)
            end)
            keymap("<C-S-Up>", event, function()
                pi.scroll_chat_history("up")
            end)
            keymap("<C-S-Down>", event, function()
                pi.scroll_chat_history("down")
            end)
            keymap("<C-{>", event, function()
                pi.scroll_chat_history_to_last_agent_response()
            end)
            keymap("<C-}>", event, function()
                pi.scroll_chat_history_to_first_agent_response()
            end)
            keymap("<C-(>", event, function()
                pi.scroll_chat_history_to_bottom()
            end)
            keymap("<S-Tab>", event, function()
                pi.invoke("/permissions-toggle-auto-accept")
            end)
            keymap("<D-S-m>", event, function()
                pi.select_model()
            end)
            keymap("<C-S-m>", event, function()
                pi.select_model_all()
            end)
            keymap("<M-m>", event, function()
                pi.cycle_model()
            end)
            keymap("<D-S-t>", event, function()
                pi.select_thinking_level()
            end)
            keymap("<M-t>", event, function()
                pi.cycle_thinking_level()
            end)
            keymap("<C-v>", event, function()
                pi.paste_image()
            end)
            keymap(NVKeyRemaps["<D-n>"], event, function()
                pi.new_session()
            end)
            keymap("<D-r>", event, function()
                pi.set_session_name()
            end)
            keymap("<D-S-x>", event, function()
                pi.compact()
            end)
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "pi-chat-attachments" },
        callback = function(event)
            keymap("<S-Up>", event, function()
                pi.focus_chat_prompt()
            end)
            keymap("<C-v>", event, function()
                pi.paste_image()
            end)
        end,
    })
end

---@param opts? { draft: string? } `draft` pre-fills the prompt; it's never sent.
function NVPi.open_float(opts)
    require("pi").show({ layout = "float", draft = opts and opts.draft })
end

---@class Limit
---@field used number Usage in percent.
---@field resets_at integer? Unix seconds; absent when the provider didn't report it.

--- One window from the `status:limits` extension entry. Absent until the provider reports it,
--- and once its reset has passed, since the usage then belongs to the previous window.
---@param state pi.StatusLineState
---@param window "h5"|"wk"
---@return Limit?
function fn.limit(state, window)
    local raw = state.extensions["status:limits"]
    if not raw then
        return nil
    end
    local limits = vim.json.decode(raw)
    local used, resets_at = limits[window], limits[window .. "Reset"]
    if not used or (resets_at and resets_at <= os.time()) then
        return nil
    end
    return { used = used, resets_at = resets_at }
end

--- Highlight for a window's usage against its plan. Without a reset time the current period
--- is unknown, so it stays uncolored.
---@param limit Limit
---@param plan LimitPlan
---@return string?
function fn.limit_hl(limit, plan)
    if not limit.resets_at then
        return nil
    end
    local elapsed = os.time() - (limit.resets_at - plan.window_seconds)
    local period_seconds = plan.window_seconds / #plan.budgets
    local period = math.max(1, math.min(#plan.budgets, math.floor(elapsed / period_seconds) + 1))
    if period == #plan.budgets then
        return fn.threshold_hl(limit.used, plan.final)
    end
    local planned = 0
    for i = 1, period do
        planned = planned + plan.budgets[i]
    end
    return fn.threshold_hl(limit.used - planned, { warning = 0, error = plan.error_margin }, true)
end

--- `warning` is inclusive unless `strict` (above the plan means strictly over it); `error` is inclusive.
---@param value number
---@param thresholds LimitThresholds
---@param strict boolean?
---@return string?
function fn.threshold_hl(value, thresholds, strict)
    if value >= thresholds.error then
        return "PiStatusLineError"
    elseif value > thresholds.warning or (not strict and value == thresholds.warning) then
        return "PiStatusLineWarning"
    end
end

--- Usage text, with the reset time while the usage is colored.
---@param icon string
---@param limit Limit
---@param plan LimitPlan
---@param hl string?
---@return string
function fn.limit_text(icon, limit, plan, hl)
    local text = ("%s %d%%"):format(icon, limit.used)
    if hl and limit.resets_at then
        text = text .. " 󱄋 " .. os.date(plan.reset_format, limit.resets_at)
    end
    return text
end

return { NVPi }
