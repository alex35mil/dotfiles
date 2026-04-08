NVPi = {
    main = "pi",
    dir = "/Users/Alex/Dev/pi.nvim",
    dependencies = {
        "HakonHarnes/img-clip.nvim",
    },
    opts = {
        debug = true,
        models = {
            { match = "opus", latest = true },
            { match = "gpt-5.3-codex", exact = true },
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
            keys = {
                accept = { "<C-CR>", modes = { "n", "i", "v" } },
                reject = { NVKeyRemaps["<C-c>"], modes = { "n", "i", "v" } },
                expand_context = { "+", modes = { "n" } },
                shrink_context = { "-", modes = { "n" } },
            },
        },
        statusline = {
            layout = {
                left = {
                    "context",
                    "  ",
                    function(state)
                        if state.extensions["permission"] then
                            return "󰐌", "PiStatusLineOn"
                        end
                    end,
                    "  ",
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
                pi.scroll_chat_history_to_last_agent_response()
            end)
            keymap("<C-(>", event, function()
                pi.scroll_chat_history_to_bottom()
            end)
            keymap("<S-Tab>", event, function()
                pi.invoke("/permission-toggle-auto-accept")
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

return { NVPi }
