require "defines"

data:extend(
  {
    {
      type = "bool-setting",
      name = mod_defines.settings.enable_supporters,
      setting_type = "startup",
      default_value = true,
      order = "a-a"
    },
    {
      type = "string-setting",
      name = mod_defines.settings.launch_order,
      setting_type = "runtime-global",
      default_value = "input order",
      order = "a-a",
      allowed_values = {"input order", "tier"}
    }
  }
)
