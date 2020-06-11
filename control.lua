require "defines"
-- local config = require("__stdlib__/stdlib/config")
-- config.skip_script_protections = true

-- Trains = require("__stdlib__/stdlib/event/trains")
-- table = require("__stdlib__/stdlib/utils/table")

Gui = {}
Gui = require("script.gui")
mod_labels = require("script/label")
require("silo-script")

new_silo = require("new_silo_script")

global.sponsors = {}
global.gui_position = {}
global.storage = {}

function init_globals()
  global.sponsors = global.sponsors or {}
  global.gui_position = global.gui_position or {}
end

function init_gui(player)
  Gui:init(player)
end

local function reinit_silo()
  if remote.interfaces["silo_script"] then
    remote.call("silo_script", "remove_tracked_item", "satellite")
    remote.call("silo_script", "set_no_victory", true)
    remote.remove_interface("silo_script")
    commands.remove_command("toggle-rockets-sent-gui")
  end
  new_silo.add_remote_interface()
  new_silo.add_commands()
end

script.on_init(
  function()
    init_globals()
    game.forces.player.recipes["patreon-satellite"].enabled = true
    -- remove silo stuff after registering interfaces
    reinit_silo()
    new_silo.on_init()

    for _, p in pairs(game.players) do
      init_gui(p)
    end
  end
)

script.on_load(
  function(event)
    reinit_silo()
    new_silo.on_load(event)
  end
)

script.on_event(
  defines.events.on_player_created,
  function(event)
    init_gui(game.players[event.player_index])
    new_silo.on_player_created(event)
  end
)

script.on_event(
  defines.events.on_player_joined_game,
  function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
      init_gui(player)
    end
  end
)

script.on_event(
  defines.events.on_gui_click,
  function(event)
    Gui:click(event)
    new_silo.on_gui_click(event)
  end
)

script.on_event(
  defines.events.on_gui_location_changed,
  function(event)
    Gui:dragged(event)
  end
)

script.on_event(
  defines.events.on_gui_text_changed,
  function(event)
    Gui:searched(event)
  end
)

local tmp_silo_storage = {}

script.on_event(
  defines.events.on_rocket_launch_ordered,
  function(event)
    local rocket_inv = event.rocket.get_inventory(defines.inventory.rocket)
    if rocket_inv and rocket_inv[1] and rocket_inv[1].valid then
      local itemStack = rocket_inv[1]

      if itemStack.name == "patreon-satellite" then
        local label = mod_labels:get_unused_label()
        local count = itemStack.count
        if label then
          label.rocket_launched = true
          label.rocket_tick = game.tick

          if label.sponsor_type == "patreon-tier-1" then
            rocket_inv.clear()
            rocket_inv.insert({name = "patreon-tier-1", count = count})
          elseif label.sponsor_type == "patreon-tier-2" then
            rocket_inv.clear()
            rocket_inv.insert({name = "patreon-tier-2", count = count})
          elseif label.sponsor_type == "patreon-tier-3" then
            rocket_inv.clear()
            rocket_inv.insert({name = "patreon-tier-3", count = count})
          end

          tmp_silo_storage[event.rocket_silo.unit_number] = label
        else
          rocket_inv.clear()
          rocket_inv.insert({name = "satellite", count = count})
        end
      end
    end
  end
)

script.on_event(
  defines.events.on_rocket_launched,
  function(event)
    new_silo.on_rocket_launched(event)
    local rocket_silo = event.rocket_silo
    local label = tmp_silo_storage[rocket_silo.unit_number]
    if not label then
      return
    end

    mod_labels:add_label(label)
    tmp_silo_storage[rocket_silo.unit_number] = nil
    game.play_sound {path = "utility/game_won"}
    game.print(
      {
        mod_defines.prefix .. "_gui.escape_message",
        label.sponsor_name,
        rocket_silo.surface.name,
        game.item_prototypes[label.sponsor_type].rocket_launch_products[1].amount
      }
    )
  end
)

script.on_configuration_changed(
  function(event)
    local changed = event.mod_changes and event.mod_changes.patreon_rockets or false

    if changed and changed.old_version == "0.1.0" then
    -- Placeholder
    end

    new_silo.on_configuration_changed(event)
  end
)

remote.add_interface(
  "patreon_rocket",
  {
    add_sponsors = function(entries)
      local label
      for _, entry in pairs(entries) do
        local tier = "patreon-tier-1"
        if entry[2] == "2" then
          tier = "patreon-tier-2"
        elseif entry[2] == "3" then
          tier = "patreon-tier-3"
        end
        label = {
          sponsor_name = entry[1],
          sponsor_type = tier
        }
        mod_labels:add_label(label)
      end
    end,
    get_totals = function()
      return #mod_labels:get_labels()
    end
  }
)
