command: "ESC=`printf \"\e\"`; ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'"

refreshFrequency: 30000 # ms

render: (output) ->
  "mem <span>#{output}</span>"

style: """
  -webkit-font-smoothing: antialiased
  font: 11px Osaka-Mono
  top: 5px
  right: 135px
  color: #D5C4A1
  span
    color: #9C9486
"""
