local M = {}

M.dashboard = {}

function M.setup()
    require "alpha.term"

    local plugin = require "alpha"
    local fs = require "utils.fs"

    M.dashboard = require "alpha.themes.dashboard"

    local section = {}

    section.padding = function(lines) return { type = "padding", val = lines } end

    -- Text-based header
    -- section.header = {
    --     type = "text",
    --     val = {
    --         [[                                                                     ]],
    --         [[       ███████████           █████      ██                     ]],
    --         [[      ███████████             █████                             ]],
    --         [[      ████████████████ ███████████ ███   ███████     ]],
    --         [[     ████████████████ ████████████ █████ ██████████████   ]],
    --         [[    ██████████████    █████████████ █████ █████ ████ █████   ]],
    --         [[  ██████████████████████████████████ █████ █████ ████ █████  ]],
    --         [[ ██████  ███ █████████████████ ████ █████ █████ ████ ██████ ]],
    --     },
    --     opts = {
    --         hl = "Type",
    --         position = "center",
    --     },
    -- }

    -- Terminal-based header
    section.header = {
        type = "terminal",
        command = "~/.config/user/config/neovim/logo.sh -c",
        width = 70,
        height = 10,
        opts = {
            redraw = true,
            window_config = {
                zindex = 1,
            },
        },
    }

    section.project = {
        type = "text",
        val = fs.root { capitalize = true },
        opts = {
            hl = "AlphaTitle",
            position = "center",
        },
    }

    section.buttons = {
        type = "group",
        val = {
            M.dashboard.button("⌃ N", "  Create file", "<Cmd>normal <C-n><CR>"),
            M.dashboard.button("⌘ E", "  Explore project", "<Cmd>normal <D-e><CR>"),
            M.dashboard.button("⌘ T", "  Find file", "<Cmd>normal <D-t><CR>"),
            M.dashboard.button("⌘ F", "  Find text", "<Cmd>normal <D-f><CR>"),
            M.dashboard.button("⌘ Q", "  Quit", "<Cmd>normal <C-q><CR>"),
        },
        opts = {
            spacing = 1,
        },
    }

    section.footer = {
        type = "text",
        val = "",
        opts = {
            hl = "Comment",
            position = "center",
        },
    }

    M.dashboard.config.layout = {
        section.padding(12),
        section.header,
        section.padding(2),
        section.project,
        section.padding(1),
        section.buttons,
        section.padding(1),
        section.footer,
    }

    M.dashboard.section = section

    plugin.setup(M.dashboard.config)
end

function M.update_footer()
    local lazy = require "lazy"

    local stats = lazy.stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

    M.dashboard.section.footer.val = "  in " .. ms .. "ms"

    pcall(function() vim.cmd "AlphaRedraw" end)
end

function M.on_open()
    local theme = require "theme.highlights"
    local lualine = require "plugins.lualine"

    lualine.hide()
    theme.disable_VertSplit()
end

function M.on_close()
    local theme = require "theme.highlights"
    local lualine = require "plugins.lualine"

    lualine.show()
    theme.enable_VertSplit()
end

return M
