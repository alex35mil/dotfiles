on start()

  set HOME to (path to home folder as string)
  set UTILS to ".alfred:shared:utils.scpt"

  set utils to load script alias (HOME & UTILS)

  tell utils to set tick to tick()


  tell application "iTerm"

    set term to (create window with default profile)
    tell term
      tell current session
        delay tick
        tell utils to clearTerminalScreen()
      end tell
    end tell

    select term

  end tell

end start
