-- To set the current location of the config:
-- defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

--- Mouse

function MovePointer(direction)
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

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function() MovePointer("left") end)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function() MovePointer("right") end)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Up", function() MovePointer("up") end)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Down", function() MovePointer("down") end)

--- Scrolla

function ToggleScrolla(status)
    local karabiner = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
    local enabled

    if status == "on" then
        enabled = 1
    elseif status == "off" then
        enabled = 0
    end

    local cmd = string.format("'%s' --set-variables '{\"scrolla\":%d}'", karabiner, enabled)

    hs.execute(cmd)
end

ScrollaOnWatcher = hs.distributednotifications.new(function() ToggleScrolla("on") end, "ScrollaDidEngage")
ScrollaOffWatcher = hs.distributednotifications.new(function() ToggleScrolla("off") end, "ScrollaDidDisengage")

ScrollaOnWatcher:start()
ScrollaOffWatcher:start()
