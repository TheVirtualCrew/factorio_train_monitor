mod_defines = {
  prefix = "train_monitor_",
}

mod_defines.settings = {
  show_notification = mod_defines.prefix .. "show_notification",
  show_leave_message = mod_defines.prefix .. "show_leave_message",
  show_arrive_message = mod_defines.prefix .. "show_arrive_message",
  show_empty_train= mod_defines.prefix .. "show_empty_train",
  downsize_rich_text = mod_defines.prefix .. "downsize_rich_text"
}

mod_defines.locale = {
  left_station = "train_monitor_train_left_station",
  left_station_2 = "train_monitor_train_left_station_2",
  arrive_station = "train_monitor_train_arrive_station",
  arrive_station_2 = "train_monitor_train_arrive_station_2",
}