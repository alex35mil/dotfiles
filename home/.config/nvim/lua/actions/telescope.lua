local M = {}

local builtin = require "telescope.builtin"
local extensions = require "telescope".extensions

local wide_layout_config = {
    width = 0.8,
}

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
        layout_strategy = "horizontal",
        layout_config = {
            width = 0.8,
            preview_width = 0.5,
        },
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
        layout_strategy = "vertical",
    })
end

function M.find_text()
    builtin.live_grep({
        hidden = true,
        no_ignore = false,
        initial_mode = "insert",
        layout_strategy = "horizontal",
    })
end

function M.diagnostics(params)
    local opts = {
        initial_mode = "normal",
        layout_strategy = "vertical",
        layout_config = wide_layout_config,
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

function M.document_symbols()
    builtin.lsp_document_symbols({
        initial_mode = "insert",
        layout_strategy = "vertical",
    })
end

function M.workspace_symbols()
    builtin.lsp_workspace_symbols({
        initial_mode = "insert",
        layout_strategy = "vertical",
    })
end

function M.todos(params)
    if not params.todo and not params.fixme and not params.priority then
        vim.api.nvim_err_writeln "No keywords specified"
        return
    end

    local keywords = {}
    if params.priority then
        table.insert(keywords, "TODO!")
        table.insert(keywords, "FIXME!")
    else
        if params.todo then
            table.insert(keywords, "TODO")
            table.insert(keywords, "TODO!")
        end
        if params.fixme then
            table.insert(keywords, "FIXME")
            table.insert(keywords, "FIXME!")
        end
    end

    vim.cmd(
        "TodoTelescope " ..
        "keywords=" .. table.concat(keywords, ",") .. " " ..
        "layout_strategy=vertical layout_config={width=0.7}"
    )
end

function M.command()
    builtin.commands({
        initial_mode = "insert",
        layout_strategy = "vertical",
        layout_config = wide_layout_config,
    })
end

return M
