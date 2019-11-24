local s = data.raw["gui-style"].default

s["train_monitor_titlebar_flow"] =
{
  type = "horizontal_flow_style",
  horizontally_stretchable = "on",
  vertical_align = "center",
  minimal_width = 90,
}

s["train_monitor_drag_widget"] =
{
  type = "empty_widget_style",
  parent = "draggable_space_header",
  horizontally_stretchable = "on",
  natural_height = 24,
  minimal_width = 24,
}
