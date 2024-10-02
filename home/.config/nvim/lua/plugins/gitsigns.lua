NVGitsigns = {
    "lewis6991/gitsigns.nvim",
    opts = {
        preview_config = {
            border = "solid",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
        },
        on_attach = function(buffer)
            local gs = package.loaded.gitsigns

            local function keymap(mapping)
                mapping = vim.tbl_extend("error", mapping, { buffer = buffer })
                K.map(mapping)
            end

            keymap({ "<D-Space>", "Git: Preview hunk", gs.preview_hunk, mode = "n" })
            keymap({ "<D-S-Space>", "Git: Stage/unstage hunk", gs.stage_hunk, mode = "n" })
            keymap({
                "<D-S-Space>",
                "Git: Stage/unstage hunk",
                function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end,
                mode = "v",
            })
            keymap({
                "<M-S-h>",
                "Git: Jump to next hunk",
                function()
                    gs.nav_hunk("next", { navigation_message = false })
                end,
                mode = { "n", "i" },
            })
            keymap({
                "<M-S-t>",
                "Git: Jump to previous hunk",
                function()
                    gs.nav_hunk("prev", { navigation_message = false })
                end,
                mode = { "n", "i" },
            })
        end,
    },
}

---@return boolean
function NVGitsigns.ensure_preview_hidden()
    local popup = require("gitsigns.popup")

    -- https://github.com/lewis6991/gitsigns.nvim/blob/863903631e676b33e8be2acb17512fdc1b80b4fb/lua/gitsigns/actions.lua#L833
    local id = "hunk"

    if popup.is_open(id) then
        popup.close(id)
        return true
    else
        return false
    end
end

return { NVGitsigns }
