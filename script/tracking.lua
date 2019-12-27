local track = {}
track.on_entity_build = function(event)
  if settings.startup[mod_defines.settings.enable_supporters].value == false then
    return
  end

  local entity = event.created_entity or event.entity

  if entity.type == 'locomotive' then
    local inventory
    if event.robot ~= nil then
      event.player_index = entity.last_user.index
      inventory = event.robot.get_inventory(defines.inventory.robot_cargo)
    elseif event.player_index then
      inventory = game.players[event.player_index].character.get_inventory(defines.inventory.character_main)
    end

    if entity == nil or entity.valid == false or inventory == nil then
      return
    end

    local tmp_label = mod_labels:get_label_by_train(entity.train)
    if tmp_label ~= false then
      return
    end

    local result = Gui:openSelectWindow(event)

    if result == false then
      entity.destroy()
      return
    end
    global.storage = {entity = entity, inventory = inventory};
  end
end

track.on_entity_removed = function (event)
  local entity = event.created_entity or event.entity

  if settings.startup[mod_defines.settings.enable_supporters].value == false then
    return
  end

  if entity == nil or entity.supports_backer_name() == false then
    return
  end

  mod_labels:remove_label_from_train(mod_labels:get_label_by_train(entity.train))
end

track.should_silence = function(entity)
end

track.get_train_names = function(train, event)
  if settings.startup[mod_defines.settings.enable_supporters].value then
    local label = mod_labels:get_label_by_train(train)
    if label then
      return {label.sponsor_name}
    end
  end

  local train_names = {}
  for _,loco in pairs(train.locomotives.front_movers) do
    if loco.supports_backer_name() and loco.backer_name  then
      table.insert(train_names, loco.backer_name)
    end
  end
  for _,loco in pairs(train.locomotives.back_movers) do
    if loco.supports_backer_name() and loco.backer_name then
      table.insert(train_names, loco.backer_name)
    end
  end

  return train_names
end

track.get_train_cargo_length = function(train)
  local length = 0;
  if #train.cargo_wagons > 0 then
    length = length + #train.cargo_wagons
  end
  if #train.fluid_wagons > 0 then
    length = length + #train.fluid_wagons
  end

  return length
end

track.get_train_contents = function(train)
  local content = {};
  for item, contents in pairs(train.get_contents()) do
    content[#content + 1] = {item = game.item_prototypes[item].localised_name, count = contents};
  end
  for item, contents in pairs(train.get_fluid_contents()) do
    content[#content + 1] = {item = game.fluid_prototypes[item].localised_name, count = math.round(contents)};
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

return track;
