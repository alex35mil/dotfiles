NVDialogs = {}

--- Wrapper around `vim.fn.confirm` that works around a Neovim 0.12 `_extui`
--- bug where the message and the `(Y)es (N)o` choice prompt are concatenated
--- onto the same line in the dialog float (see
--- `runtime/lua/vim/_core/ui2/messages.lua`). Appending a trailing newline to
--- the message forces the prompt onto its own line in extui, and is a no-op
--- visually on the legacy message grid.
---@param msg string
---@param choices string
---@param default? integer
---@param type? string
---@return integer
function NVDialogs.confirm(msg, choices, default, type)
    return vim.fn.confirm(msg .. "\n", choices, default, type)
end
