on invoke()

  set layout   to "2-cols--medium--2+2"
  set location to "~/Dev/Projects/alexfedoseev.com"

  set pane1 to { name: "root-app", exec: "cd ./blog-app" }
  set pane2 to { name: "root-api", exec: "cd ./blog-api" }
  set pane3 to { name: "app-server", exec: "cd ./blog-app && npm start" }
  set pane4 to { name: "api-server", exec: "cd ./blog-api && rails server" }

  return { layout: layout, location: location, panes: { pane1, pane2, pane3, pane4 } }

end invoke
