local fn = {}

NVDelta = {
    main = "delta",
    dir = "/Users/Alex/Dev/delta.nvim",
    opts = function()
        local pi = require("pi")
        local delta = require("delta")
        local diff = delta.diff
        local picker = delta.picker
        local spotlight = delta.spotlight

        return {
            picker = {
                initial_mode = "n",
                layout = {
                    height = { 0.5, 0.9 },
                    main = {
                        width = 0.25,
                        title = function(source)
                            local label
                            if source == "git" then
                                label = "󰫴󰫶󰬁"
                            elseif source == "agent" then
                                label = "󰫮󰫴󰫲󰫻󰬁"
                            end
                            return " 󰫱󰫲󰫹󰬁󰫮" .. " ⋆ " .. label .. " "
                        end,
                    },
                    preview = {
                        enabled = true,
                        title = " 󰫽󰫿󰫲󰬃󰫶󰫲󰬄 ",
                        width = 0.5,
                    },
                },
                sources = {
                    git = { label = "git" },
                    agent = { label = "agent", files = pi.changed_files },
                },
                actions = {
                    open = { "<CR>", fn.open(picker.actions.open) },
                    open_vsplit = { NVKeymaps.open_vsplit, fn.open(picker.actions.open_vsplit) },
                    open_hsplit = { NVKeymaps.open_hsplit, fn.open(picker.actions.open_hsplit) },
                    spotlight = { "<M-CR>", fn.open(picker.actions.spotlight) },
                    collapse = { { "<Left>", modes = "n" }, picker.actions.collapse },
                    expand = { { "<Right>", modes = "n" }, picker.actions.expand },
                    jump_up = { NVKeymaps.scroll.up, picker.actions.move(-5) },
                    jump_down = { NVKeymaps.scroll.down, picker.actions.move(5) },
                    jump_top = { { "<M-Up>", { "gg", modes = "n" } }, picker.actions.move_to_top },
                    jump_bottom = { { "<M-Down>", { "G", modes = "n" } }, picker.actions.move_to_bottom },
                    scroll_left = { "<D-S-Left>", picker.actions.scroll_horizontal(-8) },
                    scroll_right = { "<D-S-Right>", picker.actions.scroll_horizontal(8) },
                    close = { { NVKeymaps.close, { "<Esc>", modes = "n" } }, picker.actions.close },
                    toggle_stage = { "<C-CR>", picker.actions.toggle_stage },
                    reset = { "<D-x>", picker.actions.reset },
                    toggle_preview = { "<D-S-p>", picker.actions.toggle_preview },
                    scroll_preview_up = { NVKeymaps.scroll_ctx.up, picker.actions.scroll_preview(-5) },
                    scroll_preview_down = { NVKeymaps.scroll_ctx.down, picker.actions.scroll_preview(5) },
                    send_to_pi = { "<C-p>", fn.send_to_pi({ close = false }) },
                    send_to_pi_and_close = { "<D-p>", fn.send_to_pi({ close = true }) },
                },
            },
            spotlight = {
                title = "󱦇 󰬀󰫽󰫼󰬁󰫹󰫶󰫴󰫵󰬁",
                status = {
                    staged = { icon = "󰕥", label = "󰬀󰬁󰫮󰫴󰫲󰫱" },
                    unstaged = { icon = "󰒙", label = "󰬂󰫻󰬀󰬁󰫮󰫴󰫲󰫱" },
                    mixed = { icon = "", label = "󰫺󰫶󰬅󰫲󰫱" },
                    untracked = { icon = "󰫛", label = "󰬂󰫻󰬁󰫿󰫮󰫰󰫸󰫲󰫱" },
                    clean = { icon = "", label = "󰫰󰫹󰫲󰫮󰫻" },
                    conflict = { icon = "󰻌", label = "󰫰󰫼󰫻󰫳󰫹󰫶󰫰󰬁" },
                    error = { icon = "", label = "󰫲󰫿󰫿󰫼󰫿" },
                    outsider = { icon = "", label = "󰫼󰬂󰬁󰬀󰫶󰫱󰫲󰫿" },
                    no_repo = { icon = "", label = "󰫻󰫼 󰫿󰫲󰫽󰫼" },
                    non_editable = { icon = "󱀰", label = "" },
                },
                autosave_before_stage = true,
                reopen_picker_after_stage = true,
                actions = {
                    next_hunk = { "<M-S-h>", spotlight.actions.next_hunk, global = true },
                    prev_hunk = { "<M-S-t>", spotlight.actions.prev_hunk, global = true },
                    toggle_stage_file = { "<C-CR>", spotlight.actions.toggle_stage_file },
                    toggle_stage_hunk = {
                        { "<D-S-Space>", modes = { "n", "v" } },
                        spotlight.actions.toggle_stage_hunk,
                        global = true,
                    },
                    reset_file = { "<C-S-x>", spotlight.actions.reset_file, global = true },
                    reset_hunk = { { "<D-S-x>", modes = { "n", "v" } }, spotlight.actions.reset_hunk, global = true },
                },
            },
            diff = {
                file = {
                    keys = {
                        toggle_stage_file_and_close = "<C-CR>",
                        reset_file_and_close = "<C-S-x>",
                        close = NVKeymaps.close,
                    },
                },
                hunk = {
                    mode = "auto",
                    keys = {
                        scroll_up = NVKeymaps.scroll_ctx.up,
                        scroll_down = NVKeymaps.scroll_ctx.down,
                        focus_left = { "<Tab>", "<S-Left>" },
                        focus_right = { "<Tab>", "<S-Right>" },
                        close = { NVKeymaps.close, "<Esc>" },
                    },
                },
                actions = {
                    open_file_diff = { "<D-g>d", diff.actions.open_file_diff },
                    open_hunk_diff = { "<D-Space>", diff.actions.open_hunk_diff },
                },
            },
        }
    end,
    keys = function()
        local delta = require("delta")
        local picker = delta.picker
        local spotlight = delta.spotlight

        return {
            {
                "<D-S-d>",
                function()
                    picker.toggle({ source = "git" })
                end,
                mode = { "n", "i", "v" },
                desc = "Open Delta with Git source",
            },
            {
                "<C-S-d>",
                function()
                    picker.toggle({ source = "agent" })
                end,
                mode = { "n", "i", "v" },
                desc = "Open Delta with agent source",
            },
            {
                "<D-s>",
                function()
                    spotlight.toggle()
                end,
                mode = { "n", "i", "v" },
                desc = "Toggle Spotlight",
            },
        }
    end,
}

function NVDelta.cleanup()
    local delta = require("delta")
    delta.spotlight.disable_all()
    delta.diff.close_all()
end

--- Opening a file from a Delta picker starts a review flow. If Pi is in the
--- floating layout, switch to the side layout first so the reviewed
--- code is on the left in a spotlight window and the agent chat is on the right.
---@param action delta.picker.ActionHandler
---@return delta.picker.ActionHandler
function fn.open(action)
    local pi = require("pi")

    ---@param ctx delta.picker.ActionContext
    return function(ctx)
        if pi.is_visible() and pi.layout() == "float" then
            pi.toggle_layout(function(_)
                action(ctx)
            end)
        else
            action(ctx)
        end
    end
end

---@param opts { close: boolean }
---@return delta.picker.ActionHandler
function fn.send_to_pi(opts)
    local pi = require("pi")

    ---@param ctx delta.picker.ActionContext
    return function(ctx)
        local node = ctx.node
        if not node or not node.path or node.path == "" then
            return
        end

        pi.send_mention({ path = node.path }, { focus = false })

        if opts.close then
            ctx.close()
            pi.focus_chat_prompt()
        end
    end
end

return { NVDelta }
