command: "echo $($HOME/Dev/System/apps/kwm/bin/kwmc read focused)"

refreshFrequency: 1000 # ms

render: (output) ->
  "#{output}"

style: """
  -webkit-font-smoothing: antialiased
  font: 11px Osaka-Mono
  top: 5px
  left: 10px
  width: 900px
  color: #D6E7EE
  overflow: hidden
"""
