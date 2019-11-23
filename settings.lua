require 'defines';

data:extend({
  {
    type = "bool-setting",
    name = mod_defines.settings.show_notification,
    setting_type = "runtime-per-user",
    default_value = true,
    order = 'a-a'
  },
  {
    type = "bool-setting",
    name = mod_defines.settings.downsize_rich_text,
    setting_type = "runtime-per-user",
    default_value = true,
    order = 'a-b'
  },
});
