local M = {}

local builtin = require "telescope.builtin"
local extensions = require "telescope".extensions

function M.open_file_browser()
    extensions.file_browser.file_browser({
        cwd = "%:p:h",
        hidden = true,
        git_status = true,
        respect_gitignore = false,
        grouped = true,
        select_buffer = true,
        initial_mode = "normal",
        file_ignore_patterns = { "%.git/" },
    })
end

function M.buffer()
    local buffers = require "utils.buffers"
    local bufs = buffers.get_listed_bufs()

    builtin.buffers({
        initial_mode = "insert",
        sort_mru = true,
        ignore_current_buffer = #bufs > 1,
    })
end

function M.find_file()
    builtin.find_files({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
    })
end

function M.find_text()
    builtin.live_grep({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
    })
end

function M.diagnostics(params)
    local opts = {
        initial_mode = "normal",
        layout_strategy = "vertical",
        layout_config = {
            mirror = false,
            preview_cutoff = 0,
        },
    }

    if params.current_buffer then
        opts.bufnr = 0
    end

    if params.min_severity then
        opts.severity_bound = "ERROR"
        opts.severity_limit = params.min_severity
    end

    builtin.diagnostics(opts)
end

function M.todos(params)
    if not params.todo and not params.fixme then
        vim.api.nvim_err_writeln "No keywords specified"
        return
    end

    local keywords = {}
    if params.todo then table.insert(keywords, "TODO") end
    if params.fixme then table.insert(keywords, "FIXME") end

    vim.cmd(
        "TodoTelescope " ..
        "keywords=" .. table.concat(keywords, ",") .. " " ..
        "layout_strategy=vertical"
    )
end

function M.command()
    builtin.commands({
        initial_mode = "insert",
    })
end

return M
