local track = {}
track.on_entity_build = function(event)
  game.print('Build train');
  local entity = event.created_entity or event.entity
  if entity and entity.supports_backer_name() then
    table.insert(global.trains, {
      entity = entity,
      silence = false;
    })

    local train = track.find_same_train_entities(entity)
    if (#train > 1) then

    end
  end
end

track.on_entity_removed = function (event)
  local entity = event.created_entity or event.entity
  if entity and entity.supports_backer_name() then
    for _, train in pairs(global.trains) do
      if (train.entity == entity) then
      end
    end
  end
end

track.should_silence = function(entity)

end

track.get_train_names = function(train)
  local train_names = {}
  for _,loco in pairs(train.locomotives.front_movers) do
    if loco.supports_backer_name() and loco.backer_name  then
      table.insert(train_names,loco.backer_name)
    end
  end
  for _,loco in pairs(train.locomotives.back_movers) do
    if loco.supports_backer_name() and loco.backer_name then
      table.insert(train_names,loco.backer_name)
    end
  end

  return train_names
end

track.get_train_contents = function(train)
  local content = {};
  for item, contents in pairs(train.get_contents()) do
    content[#content + 1] = {item = game.item_prototypes[item].localised_name, count = contents};
  end
  for item, contents in pairs(train.get_fluid_contents()) do
    content[#content + 1] = {item = game.fluid_prototypes[item].localised_name, count = contents};
  end

  if (#content == 0) then
    content[1] = {item = 'items', count = 0}
  end

  table.sort(content, function(a, b)
    return a.count > b.count
  end);

  return content;
end

track.find_same_train_entities = function(entity)
  local ents = {}
  local train = entity.train

  if train then
    local trains = global.trains;
    for _, loco in pairs(train.locomotives.front_movers) do
      for _, t in pairs(trains) do
        if t.entity == loco then
          table.insert(ents, train)
        end
      end
    end
    for _, loco in pairs(train.locomotives.back_movers) do
      for _, t in pairs(trains) do
        if t.entity == loco then
          table.insert(ents, train)
        end
      end
    end
  end

  return ents;
end

--script.on_event(defines.events.on_built_entity, track.on_entity_build, {{filter = "rolling-stock"}});
--script.on_event(defines.events.on_robot_built_entity, track.on_entity_build, {{filter = "rolling-stock"}});
--script.on_event(defines.events.on_entity_died, track.on_entity_removed, {{filter = "rolling-stock"}});
--script.on_event(defines.events.on_player_mined_entity, track.on_entity_removed, {{filter = "rolling-stock"}});
--script.on_event(defines.events.on_robot_mined_entity, track.on_entity_removed, {{filter = "rolling-stock"}});

return track;
