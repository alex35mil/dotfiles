command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 15000 # ms

render: (output) ->
  """
  <div class="battery"
    <span></span>
    <span class="icon"></span>
  </div>
  """

update: (output, el) ->
    bat = parseInt(output)
    $(".battery span:first-child", el).text("  #{output}")
    $icon = $(".battery span.icon", el)
    $icon.removeClass().addClass("icon")
    $icon.addClass("fa #{@icon(bat)}")

icon: (output) =>
  return if output > 90
    "fa-battery-full"
  else if output > 70
    "fa-battery-three-quarters"
  else if output > 40
    "fa-battery-half"
  else if output > 20
    "fa-battery-quarter"
  else
    "fa-battery-empty"

style: """
  -webkit-font-smoothing: antialiased
  font: 9px Input
  top: 8px
  right: 180px
  color: #d5c4a1
"""
