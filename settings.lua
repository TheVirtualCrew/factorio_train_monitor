require "defines"

data:extend(
  {
    {
      type = "bool-setting",
      name = mod_defines.settings.enable_supporters,
      setting_type = "startup",
      default_value = true,
      order = "a-a"
    }
  }
)
