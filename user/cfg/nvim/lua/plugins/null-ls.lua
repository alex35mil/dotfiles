local plugin = require "null-ls"
local utils = require "null-ls.utils"

plugin.setup {
    sources = {
        -- prettier
        function()
            local bin = "node_modules/.bin/prettier"
            local cond = utils.make_conditional_utils()
            return plugin.builtins.formatting.prettier.with({
                command = cond.root_has_file(bin) and bin or "prettier",
            })
        end,
    },
}
