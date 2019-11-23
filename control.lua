
script.on_event(defines.events.on_train_changed_state, function(event)
  if (event.old_state == defines.train_state.wait_station) then
    local train = event.train;
    local train_name = {};
    local records = train.schedule.records;
    local previous = train.schedule.current - 1;
    if previous <=0 then
      previous = #records;
    end
    for _,loco in pairs(train.locomotives.front_movers) do
      if loco.supports_backer_name() and loco.backer_name  then
        table.insert(train_name,loco.backer_name)
      end
    end
    for _,loco in pairs(train.locomotives.back_movers) do
      if loco.supports_backer_name() and loco.backer_name then
        table.insert(train_name,loco.backer_name)
      end
    end

    local content = {};
    for item, contents in pairs(train.get_contents()) do
      content[#content + 1] = {item = game.item_prototypes[item].localised_name, count = contents};
    end
    for item, contents in pairs(train.get_fluid_contents()) do
      content[#content + 1] = {item = game.fluid_prototypes[item].localised_name, count = contents};
    end

    table.sort(content, function(a, b)
      return a.count > b.count
    end);

    if (#content >= 1 ) then
      -- nilaus_s32_train_delivery=__1__ going to __2__ from __3__ with __4__ : __5__
      local translate = mod_defines.locale.left_station
      if (#content == 2) then
        translate = mod_defines.locale.delivery_notification_2
      elseif (#content >= 3) then
        translate = mod_defines.locale.delivery_notification_3
      end
      local printer = {translate, table.concat(train_name, ', '),
                  records[previous].station or 'temp',
                  records[train.schedule.current].station or 'temp',
                  content[1].item,
                  content[1].count,
                  #content > 1 and (#content - 1) or nil
      }
      for _, player in pairs(game.players) do
        if (settings.get_player_settings(player)[mod_defines.settings.show_notification].value) then
          player.print(printer)
        end
      end
    end
  end
end)
