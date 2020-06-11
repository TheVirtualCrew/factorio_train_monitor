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
          "patreon-tier-3"
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
  add_label = function(self, options, index)
    local labels = global.sponsors
    local found = false
    index = index

    if #labels > 0 then
      if index ~= nil and labels[index] ~= nil then
        global.sponsors[index] = options
        found = true
      else
        for i, label in pairs(labels) do
          if options.sponsor_name == label.sponsor_name then
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
      global.sponsors[index] = nil
    end
  end,
  get_unused_label = function(self)
    local labels = self:get_labels()

    for _, label in pairs(labels) do
      if not label.rocket_launched then
        return label
      end
    end
    return false
  end
}

return label
