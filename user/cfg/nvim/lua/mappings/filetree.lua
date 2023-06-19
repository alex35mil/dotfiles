local M = {}

function M.toggle()
    local filetree = require "utils.filetree"
    local zenmode = require "utils.zenmode"

    if zenmode.is_active() then
        zenmode.deactivate()
        filetree.ensure_opened()
    else
        filetree.toggle()
    end
end

return M
