local filetype = "grug-far"

local fn = {}

NVGrugFar = {
    "MagicDuck/grug-far.nvim",
    opts = {
        headerMaxWidth = 80,
        engines = {
            ripgrep = {
                -- extraArgs = "--smart-case",
            },
        },
        prefills = {
            flags = "--hidden --fixed-strings",
            filesFilter = "!.git/",
        },
        keymaps = {
            replace = { n = "<C-r>" },
            qflist = { n = "<localleader>q" },
            syncLocations = { n = "<localleader>s" },
            syncLine = { n = "<localleader>l" },
            historyOpen = { n = "<localleader>t" },
            historyAdd = { n = "<localleader>a" },
            refresh = { n = "<localleader>f" },
            openLocation = { n = "<localleader>o" },
            openNextLocation = { n = "<down>" },
            openPrevLocation = { n = "<up>" },
            gotoLocation = { n = "<enter>" },
            pickHistoryEntry = { n = "<enter>" },
            abort = { n = "<localleader>b" },
            help = { n = "?" },
            toggleShowCommand = { n = "<A-d>" },
            previewLocation = { n = "<localleader>i" },
            close = false, -- handling it on my end
            swapEngine = false, -- don't think I will ever use it
            swapReplacementInterpreter = false, -- same
        },
    },
    keys = function()
        return {
            { "<D-S-f>", fn.open, mode = { "n", "i", "v" }, desc = "Search and Replace in the project" },
            { "<C-S-f>", fn.open_current, mode = { "n", "i", "v" }, desc = "Search and Replace in the current buffer" },
        }
    end,
}

function fn.open()
    local plugin = require("grug-far")

    local success, instance = pcall(plugin.get_instance)

    if success and instance then
        instance:open()
    else
        plugin.open({ transient = true })
    end
end

function fn.open_current()
    local plugin = require("grug-far")

    local success, instance = pcall(plugin.get_instance)

    if success and instance then
        instance:open()
    else
        plugin.open({ transient = true, prefills = { paths = vim.fn.expand("%") } })
    end
end

function fn.toggle_flag(flag)
    local plugin = require("grug-far")

    local instance = plugin.get_instance(0)

    if not instance then
        return
    end

    local state = unpack(instance:toggle_flags({ flag }))

    log.trace("grug-far: " .. flag .. " is set to " .. (state and "ON" or "OFF"))
end

function NVGrugFar.autocmds()
    local keymap = function(key, action)
        vim.keymap.set({ "n", "i" }, key, action, { buffer = true })
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-custom-keybinds", { clear = true }),
        pattern = { filetype },
        callback = function()
            keymap("<A-Up>", function()
                vim.api.nvim_win_set_cursor(vim.fn.bufwinid(0), { 2, 0 })
                vim.cmd("normal! $")
                vim.cmd("startinsert!")
            end)

            keymap("<A-i>", function()
                fn.toggle_flag("--no-ignore-vcs")
            end)
            keymap("<A-h>", function()
                fn.toggle_flag("--hidden")
            end)
            keymap("<A-c>", function()
                fn.toggle_flag("--ignore-case")
            end)
            keymap("<A-r>", function()
                fn.toggle_flag("--fixed-strings")
            end)
        end,
    })
end

---@return boolean
function NVGrugFar.ensure_current_hidden()
    local plugin = require("grug-far")

    local success, instance = pcall(plugin.get_instance, 0)

    if not success or not instance then
        return false
    end

    instance:close()

    return true
end

---@return boolean
function fn.is_active()
    return vim.bo.filetype == filetype
end

return { NVGrugFar }
