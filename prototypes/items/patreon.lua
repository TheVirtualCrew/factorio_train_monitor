require("defines")

data:extend(
  {
    {
      type = "item",
      name = "patreon-satellite",
      icon = "__patreon_rocket__/graphics/icon/nilaus-logo.png",
      icon_size = 256,
      icon_mipmaps = 4,
      subgroup = "intermediate-product",
      order = "m[patreon-satellite]",
      stack_size = 1,
      rocket_launch_products = {
        {name = "space-science-pack", amount_min = 500, amount_max = 2000}
      }
    },
    {
      type = "recipe",
      name = "patreon-satellite",
      energy_required = 5,
      enabled = false,
      category = "crafting",
      ingredients = {
        {"low-density-structure", 100},
        {"solar-panel", 100},
        {"accumulator", 100},
        {"radar", 5},
        {"processing-unit", 100},
        {"rocket-fuel", 50}
      },
      result = "patreon-satellite",
      requester_paste_multiplier = 1
    },
    {
      type = "item",
      name = "patreon-tier-1",
      flags = {"hidden"},
      icon = "__patreon_rocket__/graphics/icon/nilaus-logo.png",
      icon_size = 256,
      icon_mipmaps = 4,
      subgroup = "intermediate-product",
      order = "m[patreon-satellite-1]",
      stack_size = 1,
      rocket_launch_product = {"space-science-pack", 500}
    },
    {
      type = "item",
      name = "patreon-tier-2",
      flags = {"hidden"},
      icon = "__patreon_rocket__/graphics/icon/nilaus-logo.png",
      icon_size = 256,
      icon_mipmaps = 4,
      subgroup = "intermediate-product",
      order = "m[patreon-satellite-2]",
      stack_size = 1,
      rocket_launch_product = {"space-science-pack", 1000}
    },
    {
      type = "item",
      name = "patreon-tier-3",
      flags = {"hidden"},
      icon = "__patreon_rocket__/graphics/icon/nilaus-logo.png",
      icon_size = 256,
      icon_mipmaps = 4,
      subgroup = "intermediate-product",
      order = "m[patreon-satellite-3]",
      stack_size = 1,
      rocket_launch_product = {"space-science-pack", 2000}
    }
  }
)

table.insert(
  data.raw.technology["space-science-pack"].effects,
  {
    type = "unlock-recipe",
    recipe = "patreon-satellite"
  }
)
