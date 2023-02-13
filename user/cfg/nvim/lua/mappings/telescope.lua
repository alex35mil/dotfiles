local M = {}

local builtin = require "telescope.builtin"
local extensions = require "telescope".extensions

function M.browser()
    extensions.file_browser.file_browser({
        cwd = "%:p:h",
        hidden = true,
        respect_gitignore = false,
        grouped = true,
        select_buffer = true,
        initial_mode = "normal",
    })
end

function M.buffer()
    local buffers = require "utils.buffers"
    local bufs = buffers.get_listed_bufs()

    builtin.buffers({
        initial_mode = "normal",
        sort_mru = true,
        ignore_current_buffer = #bufs > 1,
    })
end

function M.file()
    builtin.find_files({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
    })
end

function M.text()
    builtin.live_grep({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
    })
end

function M.command()
    builtin.commands({
        initial_mode = "insert",
    })
end

return M
