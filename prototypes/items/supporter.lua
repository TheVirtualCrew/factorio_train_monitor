local name = mod_defines.unit.name
local util = require("data.sub_util")
local base = util.copy(data.raw.character.character)

data:extend {
  {
    type = "item",
    name = name,
    localised_name = {name},
    icon = base.icon,
    icon_size = base.icon_size,
    flags = {},
    subgroup = "extraction-machine",
    order = "zb" .. name,
    stack_size = 20
  }
}
