local M = {}

function M.toggle_diff()
    local git = require "utils.git"

    local current_diff = git.current_diff()

    if current_diff ~= nil then
        git.hide_current_diff()
    else
        local zenmode = require "utils.zenmode"

        zenmode.ensure_deacitvated()

        local inactive_diff_tab = git.inactive_diff()

        if inactive_diff_tab ~= nil then
            vim.api.nvim_set_current_tabpage(inactive_diff_tab)
        else
            local statusline = require "utils.statusline"

            git.open_diff()
            statusline.rename_tab("diff")
        end
    end
end

return M
