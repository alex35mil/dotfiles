local fn = {}

NVTinygit = {
    "chrisgrieser/nvim-tinygit",
    dependencies = {
        {
            "stevearc/dressing.nvim",
            opts = {
                input = {
                    relative = "cursor",
                    border = "solid",
                    mappings = {
                        n = {
                            [NVKeymaps.close] = "Close",
                            ["<Esc>"] = "Close",
                            ["<CR>"] = "Confirm",
                        },
                        i = {
                            [NVKeymaps.close] = "Close",
                            ["<CR>"] = "Confirm",
                            ["<Up>"] = "HistoryPrev",
                            ["<Down>"] = "HistoryNext",
                        },
                    },
                },
            },
        },
        "nvim-telescope/telescope.nvim",
        "rcarriga/nvim-notify",
    },
    keys = function()
        return {
            { "<D-g>s", fn.stage, mode = { "n", "i", "v" }, desc = "Git: Stage" },
            { "<D-g>c", fn.commit, mode = { "n", "i", "v" }, desc = "Git: Commit" },
            { "<D-g>a", fn.amend, mode = { "n", "i", "v" }, desc = "Git: Amend and push" },
            { "<D-g>r", fn.rename_last_commit, mode = { "n", "i", "v" }, desc = "Git: Rename last commit anrd push" },
        }
    end,
    opts = {
        backdrop = {
            enabled = false,
        },
        staging = {
            contextSize = 1,
            stagedIndicator = " ",
            keymaps = {
                stagingToggle = "<Space>",
                gotoHunk = "<CR>",
                resetHunk = "<D-r>",
            },
            moveToNextHunkOnStagingToggle = true,
        },
        commitMsg = {
            commitPreview = false,
            spellcheck = true,
            keepAbortedMsgSecs = 300,
            inputFieldWidth = 72,
            conventionalCommits = {
                enforce = false,
            },
            insertIssuesOnHash = {
                enabled = false,
                next = "<Tab>",
                prev = "<S-Tab>",
                issuesToFetch = 20,
            },
        },
        push = {
            preventPushingFixupOrSquashCommits = true,
            confirmationSound = false,
        },
    },
}

function fn.stage()
    local tinygit = require("tinygit")
    tinygit.interactiveStaging()
end

function fn.commit()
    local tinygit = require("tinygit")
    tinygit.smartCommit({ pushIfClean = true })
end

function fn.amend()
    local tinygit = require("tinygit")
    tinygit.amendNoEdit({ stageAllIfNothingStaged = false, forcePushIfDiverged = true })
end

function fn.rename_last_commit()
    local tinygit = require("tinygit")
    tinygit.amendOnlyMsg({ forcePushIfDiverged = true })
end

return { NVTinygit }
