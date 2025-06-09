local fn = {}

NVTinygit = {
    "chrisgrieser/nvim-tinygit",
    dependencies = {
        "rcarriga/nvim-notify",
    },
    keys = function()
        return {
            { "<D-g>c", fn.commit, mode = { "n", "i", "v" }, desc = "Git: Commit" },
            { "<D-g>a", fn.amend, mode = { "n", "i", "v" }, desc = "Git: Amend and push" },
            { "<D-g>r", fn.rename_last_commit, mode = { "n", "i", "v" }, desc = "Git: Rename last commit anrd push" },
        }
    end,
    opts = {
        stage = {
            contextSize = 1,
            stagedIndicator = " ",
            keymaps = {
                stagingToggle = "<Space>",
                gotoHunk = "<CR>",
                resetHunk = "<D-r>",
            },
            moveToNextHunkOnStagingToggle = true,
        },
        commit = {
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
            spellcheck = true,
            keepAbortedMsgSecs = 1200,
            keymaps = {
                normal = { abort = "<Esc>", confirm = "<CR>" },
                insert = { confirm = "<CR>" },
            },
        },
        push = {
            preventPushingFixupCommits = true,
            confirmationSound = false,
            openReferencedIssues = false,
        },
        appearance = {
            backdrop = {
                enabled = false,
            },
        },
    },
}

function NVTinygit.ensure_hidden()
    if vim.bo.filetype == "gitcommit" then
        vim.cmd.close()
        return true
    end
    return false
end

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
    tinygit.amendNoEdit({
        stageAllIfNothingStaged = false,
        forcePushIfDiverged = true,
    })
end

function fn.rename_last_commit()
    local tinygit = require("tinygit")
    tinygit.amendOnlyMsg({ forcePushIfDiverged = true })
end

return { NVTinygit }
