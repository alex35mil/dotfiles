command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  "#{output}"

style: """
  -webkit-font-smoothing: antialiased
  font: 11px Osaka-Mono
  top: 5px
  right: 50px
  color: #B16286
"""
