require "defines"

table = require('__stdlib__/stdlib/utils/table')
math = require('__stdlib__/stdlib/utils/math')

Gui = {}
Tracking = require "script.tracking"
Gui = require('script.gui')
mod_labels = require("script/label")

global.sponsors = {}
global.trains = {}
global.gui_position = {}
global.storage = {}

function downsize_rich_text(text, player_setting)
  if player_setting[mod_defines.settings.downsize_rich_text].value then
    return text:gsub("%[item=(.-)%]", "[img=item.%1]")
               :gsub("%[fluid=(.-)%]", "[img=fluid.%1]")
               :gsub("%[entity=(.-)%]", "[img=entity.%1]")
  end
  return text
end

function init_globals()
  global.sponsors = global.sponsors or {}
  global.gui_position = global.gui_position or {}
end

function init_gui(player)
  Gui:init(player)
end

function on_entity_remove(event)
  local entity = event.created_entity or event.entity

  if settings.startup[mod_defines.settings.enable_supporters].value == false then
    return
  end

  if entity == nil or entity.supports_backer_name() == false then
    return
  end

  mod_labels:remove_label_from_train(entity)
end

script.on_init(function()
  init_globals()
  for _, p in pairs(game.players) do
    init_gui(p)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  init_gui(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  if player and player.valid then
    init_gui(player)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  Gui:click(event)
end)

script.on_event(defines.events.on_gui_location_changed, function(event)
  Gui:dragged(event)
end)

script.on_event(defines.events.on_built_entity, Tracking.on_entity_build, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_robot_built_entity, Tracking.on_entity_build, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_entity_died, Tracking.on_entity_removed, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_player_mined_entity, Tracking.on_entity_removed, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_robot_mined_entity, Tracking.on_entity_removed, {{filter = "rolling-stock"}});

script.on_event(defines.events.on_train_changed_state, function(event)
  local train_left = event.old_state == defines.train_state.wait_station
  local train_arrived = event.old_state == defines.train_state.arrive_station
  if train_left or train_arrived then
    local train = event.train
    local train_name = Tracking.get_train_names(train, event)
    local records = train.schedule.records
    local previous = train.schedule.current - 1
    if previous <= 0 then
      previous = #records
    end

    -- No need to notify silenced trains
    if Tracking.should_silence(train) then
      return
    end

    local content = Tracking.get_train_contents(train)

    local printer
    for _, player in pairs(game.players) do
      local player_setting = settings.get_player_settings(player)
      local show_full = player_setting[mod_defines.settings.show_from_to_station].value
      local translate_left = show_full and mod_defines.locale.left_station_full or mod_defines.locale.left_station
      local translate_arrive = show_full and mod_defines.locale.arrive_station_full or mod_defines.locale.arrive_station
      local temp_train_names = table.deep_copy(train_name)
      if (#content >= 2) then
        translate_left = show_full and mod_defines.locale.left_station_2_full or mod_defines.locale.left_station_2
        translate_arrive = show_full and mod_defines.locale.arrive_station_2_full or mod_defines.locale.arrive_station_2
      end

      if player_setting[mod_defines.settings.show_train_name].value == false then
        temp_train_names = {"Train"};
      end

      if train_left then
        printer = { translate_left, table.concat(temp_train_names, ', '),
                    downsize_rich_text(records[previous].station or 'temp', player_setting),
                    content[1].count,
                    content[1].item,
                    #content > 1 and (#content - 1) or '',
                    player_setting[mod_defines.settings.show_from_to_station].value and
                        downsize_rich_text(records[train.schedule.current].station or 'temp', player_setting) or nil,
        }
      elseif train_arrived then
        printer = { translate_arrive, table.concat(temp_train_names, ', '),
                    downsize_rich_text(records[train.schedule.current].station or 'temp', player_setting),
                    content[1].count,
                    content[1].item,
                    #content > 1 and (#content - 1) or '',
                    show_full and downsize_rich_text(records[previous].station or 'temp', player_setting) or nil,
        }
      end

      if player_setting[mod_defines.settings.show_notification].value then
        local do_print = false
        if train_left and player_setting[mod_defines.settings.show_leave_message].value == true then
          do_print = true
        end
        if train_arrived and player_setting[mod_defines.settings.show_arrive_message].value == true then
          do_print = true
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

-- local tmp = {};
-- script.on_event(defines.events.on_train_created, function(event)
--     game.print(serpent.block(event.train.id));
--     game.print({"", "Old train ", serpent.block(event.old_train_id_1)})
--     game.print({"", "Old train2 ", serpent.block(event.old_train_id_2)})
--     if event.old_train_id_1 == nil and event.old_train_id_2 == nil then
--         -- new loco
--         table.insert(tmp, event.train.id);
--     elseif event.old_train_id_1 ~= nil and event.old_train_id_2 == nil then
--         -- Removed train?
--     elseif event.old_train_id_1 ~= nil and event.old_train_id_2 ~= nil then
--         if table.find(tmp, function(v, i, f) return v == f end, event.old_train_id_1) then
--             -- found new train
--         end
--         if table.find(tmp, function(v, i, f) return v == f end, event.old_train_id_2) then
--             -- found new train
--         end
--         -- Check if its not only adding new vehicle to another one
--         -- Has 2 trains, add gui for picking one
--
--
--         tmp = {}
--     end
-- end);

remote.add_interface('train_monitor', {
  add_sponsors = function(tier, entries)
    local label
    for _, entry in pairs(entries) do
      label = {
        sponsor_name = entry,
        sponsor_type = tier
      }
      mod_labels:add_label(label)
    end
  end
});
