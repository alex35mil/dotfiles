command: "echo $(/usr/local/bin/kwmc query space active tag)"

refreshFrequency: 1000 # ms

render: (output) ->
  """
  <div class="foc"
    <span></span>
    <span class="icon"></span>
  </div>
  """

update: (output, el) ->
    $(".foc span:first-child", el).text("  #{output}")
    $icon = $(".foc span.icon", el)
    $icon.removeClass().addClass("icon")
    $icon.addClass("fa fa-bars")

style: """
  -webkit-font-smoothing: antialiased
  color: #d5c4a1
  font: 10px Input
  height: 16px
  left: 10px
  overflow: hidden
  text-overflow: ellipsis
  top: 6px
  width: auto
"""
