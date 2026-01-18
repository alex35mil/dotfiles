local fn = {}
local cache = {}

NVOil = {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function(_, opts)
        -- Clear gitignore cache on refresh
        local refresh = require("oil.actions").refresh
        local original_refresh = refresh.callback
        refresh.callback = function(...)
            cache.gitignore = cache.new_gitignore_cache()
            original_refresh(...)
        end
        require("oil").setup(opts)
    end,
    keys = function()
        return {
            { "<D-e>", NVOil.open, mode = { "n", "i", "v", "t" }, desc = "Open file explorer" },
        }
    end,
    ---@module "oil"
    ---@type oil.SetupOpts
    opts = {
        default_file_explorer = true,
        delete_to_trash = true,
        use_default_keymaps = false,
        keymaps = {
            ["g?"] = { "actions.show_help", mode = "n" },
            ["<CR>"] = "actions.select",
            [NVKeymaps.open_vsplit] = { "actions.select", opts = { vertical = true } },
            [NVKeymaps.open_hsplit] = { "actions.select", opts = { horizontal = true } },
            [NVKeymaps.open_tab] = { "actions.select", opts = { tab = true } },
            ["<D-S-p>"] = "actions.preview",
            [NVKeymaps.scroll_ctx.up] = "actions.preview_scroll_up",
            [NVKeymaps.scroll_ctx.down] = "actions.preview_scroll_down",
            [NVKeymaps.rename] = { "^ct.", mode = "n" },
            ["<C-r>"] = "actions.refresh",
            ["&"] = { "actions.parent", mode = "n" },
            ["_"] = { "actions.open_cwd", mode = "n" },
            ["gs"] = { "actions.change_sort", mode = "n" },
            ["gx"] = { "actions.open_external", mode = "n" },
            ["<D-k>"] = { "<Cmd>w<CR>", mode = { "n", "v", "i" } },
            ["<D-n>"] = { "o", mode = "n" },
            ["<M-h>"] = { "actions.toggle_hidden", mode = "n" },
            [NVKeymaps.close] = { "actions.close", mode = "n" },
            ["<D-S-a>"] = {
                function()
                    fn.copy_path("absolute")
                end,
                mode = "n",
                desc = "Copy absolute path",
            },
            ["<D-S-r>"] = {
                function()
                    fn.copy_path("relative")
                end,
                mode = "n",
                desc = "Copy relative path",
            },
            ["<D-S-n>"] = {
                function()
                    fn.copy_path("filename")
                end,
                mode = "n",
                desc = "Copy filename",
            },
            ["<D-S-s>"] = {
                function()
                    fn.copy_path("filestem")
                end,
                mode = "n",
                desc = "Copy filestem",
            },
            ["<C-p>"] = {
                function()
                    fn.add_to_claude(false)
                end,
                mode = { "n", "v" },
                desc = "Add to Claude",
            },
            ["<D-p>"] = {
                function()
                    fn.add_to_claude(true)
                end,
                mode = { "n", "v" },
                desc = "Add to Claude and close",
            },
        },
        view_options = {
            show_hidden = true,
            -- Don't treat dot files as hidden
            is_hidden_file = function()
                return false
            end,
            -- Gray out gitignored files
            highlight_filename = function(entry)
                local dir = require("oil").get_current_dir()
                if not dir then
                    return nil
                end
                if cache.gitignore[dir][entry.name] then
                    return "Comment"
                end
                return nil
            end,
        },
        float = {
            padding = 2,
            -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            max_width = 0.6,
            max_height = 0,
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
        preview_win = {
            update_on_cursor_moved = true,
            preview_method = "scratch",
        },
        confirmation = {
            border = "rounded",
        },
    },
}

function NVOil.autocmds()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
            vim.keymap.set("n", "x", '""dd', { buffer = true, noremap = true })
            vim.keymap.set("v", "x", '""d', { buffer = true, noremap = true })
            vim.keymap.set("n", "p", '""p', { buffer = true, noremap = true })
        end,
    })
end

function NVOil.open()
    require("oil").open_float()
    -- require("oil").open_float(nil, { preview = {} }) -- preview causing issues with MOVE aciton: https://github.com/stevearc/oil.nvim/issues/632
end

function fn.parse_gitignore_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            line = line:gsub("/$", "")
            ret[line] = true
        end
    end
    return ret
end

function cache.new_gitignore_cache()
    return setmetatable({}, {
        __index = function(self, key)
            local proc = vim.system(
                { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
                { cwd = key, text = true }
            )
            local ret = fn.parse_gitignore_output(proc)
            rawset(self, key, ret)
            return ret
        end,
    })
end

cache.gitignore = cache.new_gitignore_cache()

---@param close boolean
function fn.add_to_claude(close)
    local oil = require("oil")
    local dir = oil.get_current_dir()
    if not dir then
        return
    end

    local mode = vim.fn.mode()
    local paths = {}

    if mode == "V" or mode == "v" then
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
        for lnum = start_line, end_line do
            local entry = oil.get_entry_on_line(0, lnum)
            if entry then
                table.insert(paths, dir .. entry.name)
            end
        end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    else
        local entry = oil.get_cursor_entry()
        if entry then
            table.insert(paths, dir .. entry.name)
        end
    end

    for _, path in ipairs(paths) do
        NVClaudeCode.add_file(path)
    end

    if close then
        oil.close()
        NVClaudeCode.focus()
    end
end

---@param fmt "absolute" | "relative" | "filename" | "filestem"
function fn.copy_path(fmt)
    local oil = require("oil")
    local entry = oil.get_cursor_entry()
    if not entry then
        return
    end
    local dir = oil.get_current_dir()
    if not dir then
        return
    end
    local path = dir .. entry.name
    local result = NVFS.format(path, fmt)
    if result then
        NVClipboard.yank(result)
        vim.notify("Copied: " .. result)
    end
end

return { NVOil }
