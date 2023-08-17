local spectre = require "spectre"

local M = {}

local function open(params)
    local zenmode = require "utils.zenmode"

    zenmode.ensure_deacitvated()

    if params.current_buffer then
        spectre.open_file_search { select_word = params.select_word }
    else
        if params.select_word then
            spectre.open_visual({ select_word = params.select_word })
        else
            spectre.open { select_word = params.select_word }
        end
    end
end

function M.open()
    open { select_word = false }
end

function M.word()
    open { select_word = true }
end

function M.current_buffer()
    open { current_buffer = true, select_word = false }
end

function M.word_in_current_buffer()
    open { current_buffer = true, select_word = true }
end

return M
