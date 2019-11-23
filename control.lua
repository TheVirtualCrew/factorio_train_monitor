require "defines"
Tracking = require "script.tracking"

downsize_rich_text = function(text, player_setting)
  if player_setting[mod_defines.settings.downsize_rich_text].value then
    return text:gsub("%[item=(.-)%]", "[img=item.%1]")
        :gsub("%[fluid=(.-)%]", "[img=fluid.%1]")
        :gsub("%[entity=(.-)%]", "[img=entity.%1]")
  end
  return text
end

script.on_event(defines.events.on_train_changed_state, function(event)
  local train_left = event.old_state == defines.train_state.wait_station
  local train_arrived = event.old_state == defines.train_state.arrive_station
  if train_left or train_arrived then
    local train = event.train;
    local train_name = Tracking.get_train_names(train);
    local records = train.schedule.records;
    local previous = train.schedule.current - 1;
    if previous <= 0 then
      previous = #records;
    end

    local content = Tracking.get_train_contents(train)

    local translate_left = mod_defines.locale.left_station
    local translate_arrive = mod_defines.locale.arrive_station
    if (#content >= 2) then
      translate_left = mod_defines.locale.left_station_2
      translate_arrive = mod_defines.locale.arrive_station_2
    end

    local printer
    for _, player in pairs(game.players) do
      local player_setting = settings.get_player_settings(player)

      if train_left then
        printer = { translate_left, table.concat(train_name, ', '),
                    downsize_rich_text(records[previous].station or 'temp', player_setting),
                    downsize_rich_text(records[train.schedule.current].station or 'temp', player_setting),
                    content[1].item,
                    content[1].count,
                    #content > 1 and (#content - 1) or nil
        }
      elseif train_arrived then
        printer = { translate_arrive, table.concat(train_name, ', '),
                    downsize_rich_text(records[previous].station or 'temp', player_setting),
                    content[1].count,
                    content[1].item,
                    #content > 1 and (#content - 1) or nil
        }
      end

      if player_setting[mod_defines.settings.show_notification].value then
        local do_print = false;
        if train_left and player_setting[mod_defines.settings.show_leave_message].value == true then
          do_print = true;
        end
        if train_arrived and player_setting[mod_defines.settings.show_arrive_message].value == true then
          do_print = true;
        end

        if content[1].count == 0 and player_setting[mod_defines.settings.show_empty_train].value == false then
          do_print = false
        end

        if do_print then
          player.print(printer)
        end
      end
    end
  end
end)
