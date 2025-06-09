-- To set the XDG location of the config:
-- defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

App = {
    ALACRITTY = "Alacritty",
    ZED = "Zed",
    NEOVIDE = "Neovide",
    XCODE = "Xcode",
    ARC = "Arc",
    THINGS = "Things",
    ONEPASSWORD = "1Password",
    NOTION = "Notion",
    BEAR = "Bear",
    OBSIDIAN = "Obsidian",
    TELEGRAM = "Telegram",
}

Capslock = {
    label = "󰃸",
}

InputSource = {
    EN = {
        id = "Unicode",
        label = "EN",
    },
    RU = {
        id = "Russian",
        label = "RU",
    },
}

HUD = {
    entries = {},
    delimiter = "",
}

--- Loggers

AppEventLogger = hs.logger.new("App Event", "info")
CapslockLogger = hs.logger.new("Capslock", "info")
InputSourceLogger = hs.logger.new("Input Source", "info")
HUDLogger = hs.logger.new("HUD", "info")

--- Capslock

function Capslock:isOn()
    return hs.hid.capslock.get()
end

function Capslock:update()
    HUD:updateCapslock(Capslock:isOn())
end

function Capslock:toggle()
    CapslockLogger.f("Toggling Capslock")

    local is_on = hs.hid.capslock.toggle()

    CapslockLogger.f("Is it on prior to toggle: %s", is_on)

    HUD:updateCapslock(is_on)
end

--- Input Source

function InputSource:current()
    return hs.keycodes.currentLayout()
end

function InputSource:activateEN(current)
    local EN = self.EN

    if current ~= EN.id then
        InputSourceLogger.f("Activating EN")

        hs.keycodes.setLayout(EN.id)
        HUD:updateInputSource(EN.id)
    else
        InputSourceLogger.f("Already EN. Nothing to do.")
    end
end

function InputSource:activateRU(current)
    local RU = self.RU

    if current ~= RU.id then
        InputSourceLogger.f("Activating RU")

        hs.keycodes.setLayout(RU.id)
        HUD:updateInputSource(RU.id)
    else
        InputSourceLogger.f("Already RU. Nothing to do.")
    end
end

function InputSource:toggle()
    InputSourceLogger.f("Updating input source")

    local EN = self.EN

    local current = InputSource:current()

    InputSourceLogger.f("Current input source: %s", current)

    if current == EN.id then
        InputSource:activateRU(current)
    else
        InputSource:activateEN(current)
    end
end

--- HUD

-- HUD Style:
--  * Keys which affect the alert rectangle:
--    * fillColor   - a table as defined by the `hs.drawing.color` module to specify the background color for the alert, defaults to { white = 0, alpha = 0.75 }.
--    * strokeColor - a table as defined by the `hs.drawing.color` module to specify the outline color for the alert, defaults to { white = 1, alpha = 1 }.
--    * strokeWidth - a number specifying the width of the outline for the alert, defaults to 2
--    * radius      - a number specifying the radius used for the rounded corners of the alert box, defaults to 27
--
--  * Keys which affect the text of the alert when the message is a string (note that these keys will be ignored if the message being displayed is already an `hs.styledtext` object):
--    * textColor   - a table as defined by the `hs.drawing.color` module to specify the message text color for the alert, defaults to { white = 1, alpha = 1 }.
--    * textFont    - a string specifying the font to be used for the alert text, defaults to ".AppleSystemUIFont" which is a symbolic name representing the systems default user interface font.
--    * textSize    - a number specifying the font size to be used for the alert text, defaults to 27.
--    * textStyle   - an optional table, defaults to `nil`, specifying that a string message should be converted to an `hs.styledtext` object using the style elements specified in this table.  This table should conform to the key-value pairs as described in the documentation for the `hs.styledtext` module.  If this table does not contain a `font` key-value pair, one will be constructed from the `textFont` and `textSize` keys (or their defaults); likewise, if this table does not contain a `color` key-value pair, one will be constructed from the `textColor` key (or its default).
--    * padding     - the number of pixels to reserve around each side of the text and/or image, defaults to textSize/2
--    * atScreenEdge   - 0: screen center (default); 1: top edge; 2: bottom edge . Note when atScreenEdge>0, the latest alert will overlay above the previous ones if multiple alerts visible on same edge; and when atScreenEdge=0, latest alert will show below previous visible ones without overlap.
--    * fadeInDuration  - a number in seconds specifying the fade in duration of the alert, defaults to 0.15
--    * fadeOutDuration - a number in seconds specifying the fade out duration of the alert, defaults to 0.15

HUDStyle = {
    strokeWidth = 30,
    strokeColor = { white = 0.5, alpha = 0 },
    fillColor = { white = 0, alpha = 0.3 },
    textColor = { white = 1, alpha = 1 },
    textFont = "BerkeleyMono Nerd Font",
    textSize = 60,
    radius = 10,
    atScreenEdge = 2,
    fadeInDuration = 0,
    fadeOutDuration = 0,
    padding = 60,
}

function HUD:style(frame)
    -- Base style
    local style = {
        strokeWidth = 30,
        strokeColor = { white = 0.5, alpha = 0 },
        fillColor = { white = 0, alpha = 0.3 },
        textColor = { white = 1, alpha = 1 },
        textFont = "BerkeleyMono Nerd Font",
        fadeInDuration = 0,
        fadeOutDuration = 0,
    }

    local breakpoint = 1500
    local isSmallScreen = frame.w < breakpoint

    style.textSize = isSmallScreen and 20 or 60
    style.padding = isSmallScreen and 10 or 60
    style.radius = isSmallScreen and 5 or 10
    style.atScreenEdge = isSmallScreen and 1 or 2

    return style
end

function HUD:show(label)
    local entries = {}

    local screens = hs.screen.allScreens()

    for i, screen in ipairs(screens) do
        local frame = screen:fullFrame()
        local style = HUD:style(frame)
        entries[i] = hs.alert(label, style, screen, "forever")
    end

    self.entries = entries
end

function HUD:updateInputSource(input_source)
    HUD:setState({
        ["input_source"] = input_source,
        ["capslock"] = false, -- when changing input source, capslock goes off
    })
end

function HUD:updateCapslock(capslock)
    HUD:setState({
        ["input_source"] = InputSource:current(),
        ["capslock"] = capslock,
    })
end

function HUD:setState(state)
    local RU = InputSource.RU

    HUDLogger.f("Updating HUD. Input Source: %s. Capslock: %s", state.input_source, state.capslock)

    HUD:hide()

    if state.input_source == RU.id and not state.capslock then
        HUD:show(RU.label)
    elseif state.input_source == RU.id and state.capslock then
        HUD:show(string.format("%s %s %s", RU.label, HUD.delimiter, Capslock.label))
    elseif state.capslock then
        HUD:show(string.format(" %s ", Capslock.label))
    elseif not state.capslock then
        -- already hidden
    end
end

function HUD:hide()
    hs.alert.closeAll(0)
end

function HUD:update()
    HUD:setState({
        ["input_source"] = InputSource:current(),
        ["capslock"] = Capslock:isOn(),
    })
end

--- Let's go

HUD:update()

-- AppWatcher:start()

hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "Space", function()
    InputSource:toggle()
end)
