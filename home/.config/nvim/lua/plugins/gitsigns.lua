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
