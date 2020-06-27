--
-- Created by TheVirtualCrew.
--

--[[
label = {
  type = { },
  name = "",
  rocket_launched = false,
  rocket_tick = 0
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
          "patreon-tier-4"
        },
        selected = "patreon-tier-1"
      },
      sponsor_name = ""
    }
  end,
  get_labels = function(self)
    return global.sponsors
  end,
  get_label_by_index = function(self, index)
    if global.sponsors[index] then
      return global.sponsors[index]
    end
    return false
  end,
  get_label_index_by_name = function(self, name)
    local labels = global.sponsors
    for index, label in pairs(labels) do
      if label.sponsor_name == name then
        return index
      end
    end
    return false
  end,
  add_label = function(self, options, index)
    local labels = global.sponsors
    local found = false
    index = index

    if #labels > 0 then
      if index ~= nil and labels[index] ~= nil then
        local label = labels[index]
        options.rocket_launched = label.rocket_launched
        options.rocket_tick = label.rocket_tick
        global.sponsors[index] = options
        found = true
      else
        for i, label in pairs(labels) do
          if options.sponsor_name == label.sponsor_name then
            local lbltype = options.sponsor_type
            options = label
            options.sponsor_type = lbltype
            options.hidden = false

            global.sponsors[i] = options
            found = true
            break
          end
        end
      end
    end
    if found == false then
      options.rocket_launched = options.rocket_launched or false
      options.rocket_tick = options.rocket_tick or nil
      table.insert(global.sponsors, options)
    end

    return found
  end,
  remove_label = function(self, index)
    if global.sponsors[index] then
      local label = global.sponsors[index]
      if label.rocket_launched ~= nil then
        label.hidden = true
      else
        global.sponsors[index] = nil
      end
    end
  end,
  get_unused_label = function(self, sponsor_type)
    local labels = self:get_labels()

    for _, label in pairs(labels) do
      if
        not label.rocket_launched and
          ((sponsor_type ~= nil and label.sponsor_type == sponsor_type) or sponsor_type == nil)
       then
        return label
      end
    end
    return false
  end
}

return label
