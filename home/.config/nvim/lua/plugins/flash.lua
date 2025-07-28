local fn = {}

NVFlash = {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = false,
    keys = function()
        return {
            { "<D-j>", mode = { "n", "i", "x", "o", "t" }, fn.search, desc = "Search" },
        }
    end,
    opts = {
        labels = "htnueosaldibxgpkmfycwjrqvz",
        search = {
            multi_window = true,
            forward = true,
            wrap = true,
            mode = "fuzzy",
            max_length = false,
            exclude = {
                "notify",
                "cmp_menu",
                "noice",
                "flash_prompt",
                function(win)
                    return not vim.api.nvim_win_get_config(win).focusable
                end,
            },
        },
        jump = {
            nohlsearch = true,
            autojump = false,
        },
        label = {
            uppercase = false,
            current = false,
            after = false,
            before = true,
            style = "overlay",
            reuse = "lowercase",
            distance = true,
            min_pattern_length = 0,
        },
        highlight = {
            backdrop = true,
            matches = true,
        },
        modes = {
            search = {
                enabled = false,
            },
            char = {
                enabled = true,
                keys = { "f", "F", "t", "T" },
                autohide = false,
                jump_labels = false,
                multi_line = true,
                char_actions = function(motion)
                    return {
                        [motion:lower()] = "next",
                        [motion:upper()] = "prev",
                    }
                end,
                search = { wrap = false },
                highlight = { backdrop = true },
                jump = {
                    register = false,
                    autojump = false,
                },
            },

            -- TODO: Review treesitter-related settings

            treesitter = {
                labels = "abcdefghijklmnopqrstuvwxyz",
                jump = { pos = "range", autojump = true },
                search = { incremental = false },
                label = { before = true, after = true, style = "inline" },
                highlight = {
                    backdrop = false,
                    matches = false,
                },
            },
            treesitter_search = {
                jump = { pos = "range" },
                search = { multi_window = true, wrap = true, incremental = false },
                remote_op = { restore = true },
                label = { before = true, after = true, style = "inline" },
            },
            remote = {
                remote_op = { restore = true, motion = true },
            },
        },
        prompt = {
            enabled = true,
            prefix = { { " 󱅥  ", "FlashPromptIcon" } },
            win_config = {
                relative = "editor",
                width = 50, -- when <=1 it's a percentage of the editor width
                height = 1,
                row = -1, -- when negative it's an offset from the bottom
                col = math.floor(vim.go.columns / 2) - 25, -- 25 = width / 2 -- when negative it's an offset from the right
                zindex = 2000,
            },
        },
        remote_op = {
            restore = false,
            motion = false,
        },
    },
}

function fn.jump()
    require("flash").jump({ search = { mode = "search" } })
end

function fn.search()
    if vim.fn.mode() ~= "t" then
        fn.jump()
    else
        NVKeys.send("<C-\\><C-n>", { mode = "n" })

        local timeout = 1000 -- 1 second
        local interval = 10 -- check every 10ms
        local elapsed = 0

        local timer = vim.uv.new_timer()

        if not timer then
            log.error("Failed to create timer")
            return
        end

        timer:start(
            0,
            interval,
            vim.schedule_wrap(function()
                if vim.fn.mode() == "n" then
                    timer:stop()
                    timer:close()
                    fn.jump()
                elseif elapsed >= timeout then
                    timer:stop()
                    timer:close()
                    log.error("Timeout entering normal mode")
                else
                    elapsed = elapsed + interval
                end
            end)
        )
    end
end

return { NVFlash }
