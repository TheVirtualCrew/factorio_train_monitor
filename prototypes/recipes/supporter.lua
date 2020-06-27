local name = mod_defines.unit.name

data:extend {
  {
    type = "recipe",
    name = name,
    localised_name = {name},
    enabled = true,
    ingredients = {
      {"iron-plate", 10},
      {"iron-gear-wheel", 5},
      {"iron-stick", 10}
    },
    energy_required = 2,
    result = name
  }
}
