on start(projectId)

  set HOME to (path to home folder as string)
  set PROJECTS to ".alfred:projects:"
  set LAYOUTS to ".alfred:layouts:"

  set descriptor to load script alias (HOME & PROJECTS & projectId & ".scpt")

  tell descriptor to set projectDefinition to invoke()

  set layout   to layout of projectDefinition
  set location to location of projectDefinition
  set panes    to panes of projectDefinition

  set project to load script alias (HOME & LAYOUTS & layout & ".scpt")

  tell project to start(projectId, location, panes)

end start
