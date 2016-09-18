on invoke()

  set layout   to "2-cols--medium--2+1"
  set location to "~/Dev/Projects/shakacode.com/fng"

  set pane1 to { name: "root" }
  set pane2 to { name: "client",  exec: "cd ./client" }
  set pane3 to { name: "servers", exec: "foreman start -f Procfile.dev" }

  return { layout: layout, location: location, panes: { pane1, pane2, pane3 } }

end invoke
