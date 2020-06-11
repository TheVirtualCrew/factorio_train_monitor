require("defines")

local function get_font(name, size)
  return {
    type = "font",
    name = mod_defines.prefix .. "_" .. name,
    from = "default",
    size = size,
    border = true
  }
end

data:extend(
  {
    {
      type = "sprite",
      name = "header_sort_down_white",
      filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
      size = {16, 16},
      scale = 0.5
    },
    {
      type = "sprite",
      name = "header_sort_down",
      filename = "__core__/graphics/arrows/table-header-sort-arrow-down-active.png",
      size = {16, 16},
      scale = 0.5
    },
    {
      type = "sprite",
      name = "header_sort_up",
      filename = "__core__/graphics/arrows/table-header-sort-arrow-up-active.png",
      size = {16, 16},
      scale = 0.5
    },
    get_font("micro", 10),
    get_font("tiny", 12),
    get_font("small", 14),
    get_font("default-small", 16),
    get_font("default", 18),
    get_font("large", 20),
    get_font("huge", 22)
  }
)

data.raw["gui-style"].default["header_sort_button_base"] = {
  type = "button_style",
  minimal_height = 18,
  minimal_width = 60,
  padding = 2,
  top_padding = 0,
  margin = 0,
  font = "default-bold",
  font_color = default_font_color,
  vertical_align = "center",
  horizontal_align = "center",
  default_font_color = default_font_color,
  hovered_font_color = default_font_color,
  disabled_font_color = default_font_color,
  clicked_font_color = default_font_color,
  clicked_vertical_offset = 0, -- text/icon goes down on click
  default_graphical_set = {},
  hovered_graphical_set = {},
  clicked_graphical_set = {}
}
