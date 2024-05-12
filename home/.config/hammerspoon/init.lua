-- To set the current location of the config:
-- defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

local function move_pointer(direction)
    local pos = hs.mouse.getAbsolutePosition()
    local screen = hs.screen.mainScreen():fullFrame()
    local step_factor = 4

    if direction == "left" then
        pos.x = pos.x - (screen.w / step_factor)
    elseif direction == "right" then
        pos.x = pos.x + (screen.w / step_factor)
    elseif direction == "up" then
        pos.y = pos.y - (screen.h / step_factor)
    elseif direction == "down" then
        pos.y = pos.y + (screen.h / step_factor)
    else
    end

    hs.mouse.setAbsolutePosition(pos)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function() move_pointer("left") end)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function() move_pointer("right") end)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Up", function() move_pointer("up") end)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Down", function() move_pointer("down") end)
