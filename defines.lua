mod_defines = {
  prefix = "train_monitor",
}

mod_defines.settings = {
  show_notification = mod_defines.prefix .. "_show_notification",
  show_train_name = mod_defines.prefix .. "_show_train_name",
  show_leave_message = mod_defines.prefix .. "_show_leave_message",
  show_arrive_message = mod_defines.prefix .. "_show_arrive_message",
  show_empty_train= mod_defines.prefix .. "_show_empty_train",
  show_from_to_station= mod_defines.prefix .. "_show_from_to_station",
  downsize_rich_text = mod_defines.prefix .. "_downsize_rich_text",
  enable_supporters = mod_defines.prefix .. "_enable_supporters",
}

mod_defines.locale = {
  left_station = mod_defines.prefix .. ".train_left_station",
  left_station_2 = mod_defines.prefix .. ".train_left_station_2",
  left_station_full = mod_defines.prefix .. ".train_left_station_full",
  left_station_2_full = mod_defines.prefix .. ".train_left_station_2_full",
  arrive_station = mod_defines.prefix .. ".train_arrive_station",
  arrive_station_2 = mod_defines.prefix .. ".train_arrive_station_2",
  arrive_station_full = mod_defines.prefix .. ".train_arrive_station_full",
  arrive_station_2_full = mod_defines.prefix .. ".train_arrive_station_2_full",
}
mod_defines.gui = {
  button_title = mod_defines.prefix .."_gui.button_title",
  frame_title = mod_defines.prefix .."_gui.frame_title",
  add_new = mod_defines.prefix .."_gui.add_new",
  delete = mod_defines.prefix .."_gui.delete",
  edit = mod_defines.prefix .."_gui.edit",
  table_action = mod_defines.prefix .."_gui.table_action",
  table_used = mod_defines.prefix .."_gui.table_used",
  table_name = mod_defines.prefix .."_gui.table_name",
  table_type = mod_defines.prefix .."_gui.table_type",
  sponsor_type = mod_defines.prefix .."_gui.sponsor_type",
  sponsor_name = mod_defines.prefix .."_gui.sponsor_name",
  save = mod_defines.prefix .."_gui.save",
  cancel = mod_defines.prefix .."_gui.cancel",
  yes = mod_defines.prefix .."_gui.yes",
  no = mod_defines.prefix .."_gui.no",
}