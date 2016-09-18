on tick()
  return 0.7
end tick

on tickTock()
  return 1.2
end tickTock

on clearTerminalScreen()
  tell application "System Events" to keystroke "k" using command down
  delay tickTock
end clearTerminalScreen
