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
    name = mod_defines.settings.show_train_name,
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
  {
    type = "bool-setting",
    name = mod_defines.settings.show_leave_message,
    setting_type = "runtime-per-user",
    default_value = true,
    order = 'b-a'
  },
  {
    type = "bool-setting",
    name = mod_defines.settings.show_arrive_message,
    setting_type = "runtime-per-user",
    default_value = true,
    order = 'b-b'
  },
  {
    type = "bool-setting",
    name = mod_defines.settings.show_from_to_station,
    setting_type = "runtime-per-user",
    default_value = true,
    order = 'b-b'
  },
  {
    type = "bool-setting",
    name = mod_defines.settings.show_empty_train,
    setting_type = "runtime-per-user",
    default_value = false,
    order = 'b-c'
  },
  {
    type = "bool-setting",
    name = mod_defines.settings.enable_supporters,
    setting_type = "startup",
    default_value = true,
    order = 'a-a'
  },
});
