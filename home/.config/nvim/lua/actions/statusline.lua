local M = {}

function M.toggle_filename()
    local plugin = require "lualine"
    local statusline = require "plugins.lualine"
    local config = plugin.get_config()

    for _, section in pairs(config.sections) do
        for _, component in ipairs(section) do
            if type(component) == "table" and component[1] == "filename" then
                if component.path == 0 then
                    component.path = 1
                else
                    component.path = 0
                end
            end
        end
    end

    plugin.setup(config)
    statusline.ensure_tabline_visibility_mode()
end

return M