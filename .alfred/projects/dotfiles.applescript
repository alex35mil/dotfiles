on invoke()

  set layout   to "2-rows--large--1+1"
  set location to "~/Dev/System/dotfiles"

  set pane1 to { name: "primary" }
  set pane2 to { name: "secondary" }

  return { layout: layout, location: location, panes: { pane1, pane2 } }

end invoke
