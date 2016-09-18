command: "ESC=`printf \"\e\"`; ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}'"

refreshFrequency: 2000 # ms

render: (output) ->
  """
  <div class="cpu"
    <span></span>
    <span class="icon"></span>
  </div>
  """

update: (output, el) ->
    $(".cpu span:first-child", el).text("  #{output}")
    $icon = $(".cpu span.icon", el)
    $icon.removeClass().addClass("icon")
    $icon.addClass("fa fa-bar-chart")

style: """
  -webkit-font-smoothing: antialiased
  color: #d5c4a1
  font: 10px Input
  right: 320px
  top: 6px
"""
