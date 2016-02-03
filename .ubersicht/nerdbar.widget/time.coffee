command: "date +\"%H:%M\""

refreshFrequency: 10000 # ms

render: (output) ->
  "#{output}"

style: """
  -webkit-font-smoothing: antialiased
  font: 11px Osaka-Mono
  top: 5px
  right: 10px
  color: #458588
"""
