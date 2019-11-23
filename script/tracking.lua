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

script.on_event(defines.events.on_built_entity, track.on_entity_build, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_robot_built_entity, track.on_entity_build, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_entity_died, track.on_entity_removed, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_player_mined_entity, track.on_entity_removed, {{filter = "rolling-stock"}});
script.on_event(defines.events.on_robot_mined_entity, track.on_entity_removed, {{filter = "rolling-stock"}});
