--
-- Created by TheVirtualCrew.
--

--[[
label = {
  type = { },
  name = "",
  train_id,
}
]] --
local label = {
  storage = nil,
  get_config = function()
    return {
      sponsor_type = {
        options = {
          "patreon-tier-1",
          "patreon-tier-2",
          "patreon-tier-3",
          "twitch-tier-1",
          "twitch-tier-2",
          "twitch-tier-3",
        },
        selected = "patreon-tier-1"
      },
      sponsor_name = "",
    }
  end,
  create_train_label = function(self, train, options)
    options.train = train
    train.backer_name = options.sponsor_name
    self:add_label(options);
  end,
  get_labels = function(self)
    return global.sponsors
  end,
  get_label_by_locomotive = function(self, train)
    if train == nil then
      return false
    end

    local labels = global.sponsors
    if #labels > 0 then
      for _, label in pairs(labels) do
        if train == label.train then
          return label
        end
      end
    end

    return false
  end,
  get_label_by_index = function(self, index)
    if global.sponsors[index] then
      return global.sponsors[index]
    end
    return false
  end,
  add_label = function(self, options, index)
    local labels = global.sponsors
    local found = false;
    index = index

    if #labels > 0 then
      if index ~= nil and labels[index] ~= nil then
        local label = labels[index]
        if label.train and label.train.valid then
          options.train = label.train
          options.train.backer_name = options.sponsor_name
        end
        global.sponsors[index] = options
        found = true
      else
        for i, label in pairs(labels) do
          if options.sponsor_name == label.sponsor_name then
            if label.train then
              options.train = label.train
              options.train.backer_name = options.sponsor_name
            end
            global.sponsors[i] = options
            found = true
            break
          end
        end
      end
      for i, label in pairs(labels) do
        if options.sponsor_name == label.sponsor_name then
          if label.train then
            options.train = label.train
            options.train.backer_name = options.sponsor_name
          end
          global.sponsors[i] = options
          found = true
          break
        end
      end
    end
    if found == false then
      table.insert(global.sponsors, options)
    end
  end,
  remove_label = function(self, index)
    if global.sponsors[index] then
      local label = global.sponsors[index];
      if label.train then
        self:remove_label_from_train(label, true)
      end
      global.sponsors[index] = nil
    end
  end,
  remove_label_from_train = function(self, current_label, replace)
    local labels = self:get_labels()
    local removed = false
    replace = replace or false;
    if current_label.train and current_label.train.valid == false then
        current_label.train = nil
        return
    end
    for _, label in pairs(labels) do
      if label.train and current_label.train and label.train == current_label.train then
        current_label.train.backer_name = "Thy little cheater"
        removed = true;
      end
    end

    if replace and removed then
      local new_label = self:get_unused_label(current_label.sponsor_type)
      if new_label then
        self:create_train_label(current_label.train, new_label)
        current_label.train = nil;
      end
    elseif removed then
      current_label.train = nil
    end
  end,
  get_unused_label = function(self, type)
    local labels = self:get_labels();
    type = type or nil

    for _, label in pairs(labels) do
      if label.train == nil and ((type ~= nil and label.sponsor_type == type) or type == nil) then
        return label
      end
    end
    return false
  end,
}

return label;
