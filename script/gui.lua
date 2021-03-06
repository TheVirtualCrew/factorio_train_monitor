--
-- Created by TheVirtualCrew.
--

local mod_gui = require("mod-gui")
require("util")

local sort_order = {desc = "DESC", asc = "ASC"}
local temp = {}
local sort = {}

function parse_config_from_gui(gui, config)
  local config_table = gui.config_table
  local values = {}
  if not config_table then
    error("Trying to parse config from gui with no config table present")
  end
  for name, value in pairs(config) do
    if config_table[name .. "_box"] then
      local text = config_table[name .. "_box"].text
      values[name] = text
    end
    if type(value) == "boolean" then
      if config_table[name] then
        values[name] = config_table[name .. "_boolean"].state
      end
    end
    if type(value) == "table" then
      local menu = config_table[name .. "_dropdown"]
      if not menu then
        game.print("Error trying to read drop down menu of gui element " .. name)
        return
      end
      values[name] = config[name].options[menu.selected_index]
    end
  end
  return values
end

function make_config_table(gui, config)
  local config_table = gui.config_table
  if config_table then
    config_table.clear()
  else
    config_table = gui.add {type = "table", name = "config_table", column_count = 2}
    config_table.style.column_alignments[2] = "right"
  end
  local items = game.item_prototypes
  for k, name in pairs(config) do
    local label
    if type(name) == "table" then
      label = config_table.add {type = "label", name = k, tooltip = {k .. "_tooltip"}}
      local menu = config_table.add {type = "drop-down", name = k .. "_dropdown"}
      local index
      for j, option in pairs(name.options) do
        if items[option] then
          menu.add_item(items[option].localised_name)
        else
          menu.add_item({mod_defines.prefix .. "_gui." .. option})
        end

        if option == name.selected then
          index = j
        end
      end
      menu.selected_index = index or 1
      if name.tooltip then
        label.tooltip = name.tooltip
      end
    elseif tostring(type(name)) == "boolean" then
      label = config_table.add {type = "label", name = k, tooltip = {k .. "_tooltip"}}
      config_table.add {type = "checkbox", name = k .. "_" .. tostring(type(name)), state = name}
    else
      label = config_table.add {type = "label", name = k, tooltip = {k .. "_tooltip"}}
      local input = config_table.add {type = "textfield", name = k .. "_box"}
      input.text = name
      input.style.maximal_width = 100
    end
    label.caption = {"", {mod_defines.prefix .. "_gui." .. k}, {"colon"}}
  end
end

local function addSortHeader(list_table, name, label, player_index)
  local main_button =
    list_table.add {
    type = "button",
    name = "sponsor_list_table_hsort" .. name,
    -- caption = {mod_defines.gui.table_type},
    style = "header_sort_button_base"
  }

  local sprite = "header_sort_down_white"
  if sort[player_index] and sort[player_index].sort and sort[player_index].sort.column == tonumber(name) then
    if sort[player_index].sort.dir == sort_order.desc then
      sprite = "header_sort_down"
    else
      sprite = "header_sort_up"
    end
  end

  local sorter =
    main_button.add {
    type = "sprite",
    name = "sponsor_list_table_hsort" .. name .. "_",
    sprite = sprite
  }
  sorter.style.top_padding = 6
  local text =
    main_button.add {
    type = "label",
    name = "sponsor_list_table_hsort" .. name .. "__",
    caption = label,
    style = "bold_label"
  }
  text.style.left_padding = 16
  text.style.top_padding = -1

  return main_button
end

local interface = {
  init = function(self, player)
    self.initTopButton(player)
  end,
  initTopButton = function(player)
    if settings.startup[mod_defines.settings.enable_supporters].value == false then
      return
    end
    -- create button list top
    local button_flow = mod_gui.get_button_flow(player)

    if not button_flow.sponsor_button then
      button_flow.add {
        type = "button",
        caption = {mod_defines.gui.button_title},
        name = "sponsor_button",
        style = mod_gui.button_style
      }
    end
    global.gui_position[player.index] =
      global.gui_position[player.index] or {x = 300 * player.display_scale, y = 300 * player.display_scale}
  end,
  click = function(self, event)
    local triggers = {
      sponsor_button = self.clickListButton,
      sponsor_list_table_add_new = self.clickAddButton,
      sponsor_list_search_button = self.clickSearchButton,
      sponsor_list_close = self.clickListButton,
      sponsor_list_table_close = self.clickListButton,
      sponsor_list_table_add_new_save = self.clickSaveAddButton,
      sponsor_list_table_add_new_cancel = self.clickCancelAddButton,
      sponsor_list_table_apply_save = self.clickConfirmSelectButton,
      sponsor_list_table_apply_cancel = self.clickCancelSelectButton
    }
    local match_trigger = {
      sponsor_list_table_ledit = self.clickEditButton,
      sponsor_list_table_ldelete = self.clickRemoveButton,
      sponsor_list_table_hsort = self.clickSortHeader
    }

    local element = event.element
    if not element.valid then
      return
    end

    if element.name then
      local button_function = triggers[element.name]
      if button_function then
        button_function(self, event)
        return
      end
      for key, f in pairs(match_trigger) do
        if element.name:find(key) ~= nil then
          local index = element.name:gsub(key, ""):gsub("_", "")
          index = tonumber(index)
          f(self, event, index)
          break
        end
      end
    end
  end,
  dragged = function(self, event)
    local player_id = event.player_index
    if player_id then
      local player = game.players[player_id]

      if player.gui.screen.sponsor_list then
        local element = event.element

        if element.name == "sponsor_list" then
          global.gui_position[player_id] = element.location
        end
      end
    end
  end,
  searched = function(self, event)
    local player_id = event.player_index
    if player_id then
      local player = game.players[player_id]

      if player.gui.screen.sponsor_list then
        local element = event.element

        if element.name == "sponsor_list_search_field" then
          if sort[player_id] == nil then
            sort[player_id] = {
              search = "",
              sort = {}
            }
          end
          sort[player_id].search = element.text
          self:addItemsToListTable(nil, mod_labels:get_labels(), event)
        end
      end
    end
  end,
  clickListButton = function(self, event)
    -- if open destroy
    -- if closed open list and show list
    local player = game.players[event.player_index]
    local center_gui = player.gui.screen

    if center_gui.sponsor_list then
      global.gui_position[event.player_index] = center_gui.sponsor_list.location
      center_gui.sponsor_list.destroy()
    else
      --button_table.add { type = "button", name = "sponsor_list_table_close", caption = { "close" } }
      local frame =
        center_gui.add({type = "frame", name = "sponsor_list", direction = "vertical", style = "dialog_frame"})
      frame.location = global.gui_position[event.player_index]
      frame.style.vertical_align = "center"
      frame.style.horizontal_align = "center"
      local flow = frame.add({type = "flow", name = "train_monitor_fflow", style = "train_monitor_titlebar_flow"})
      flow.style.horizontally_stretchable = "on"
      flow.style.vertical_align = "center"

      flow.add({type = "label", caption = {mod_defines.gui.frame_title}, style = "frame_title"})
      local widget = flow.add({type = "empty-widget", style = "train_monitor_drag_widget", name = "sponsor_drag"})
      widget.drag_target = frame

      local searchfield = flow.add({type = "textfield", name = "sponsor_list_search_field"})
      searchfield.clear_and_focus_on_right_click = true
      searchfield.visible = false

      if sort[event.player_index] and sort[event.player_index].search then
        searchfield.text = sort[event.player_index].search
      end

      flow.add(
        {
          type = "sprite-button",
          sprite = "utility/search_icon",
          style = "search_button",
          name = "sponsor_list_search_button"
        }
      )

      flow.add(
        {type = "sprite-button", sprite = "utility/close_white", style = "close_button", name = "sponsor_list_close"}
      )

      local scroll = frame.add {type = "scroll-pane", name = "sponsor_list_scroll", vertical_scroll_policy = "always"}
      scroll.style.height = 250
      local list_table =
        scroll.add {
        type = "table",
        name = "sponsor_list_table",
        column_count = 4,
        style = "table_with_selection"
      }

      local labels = mod_labels:get_labels()
      self:addItemsToListTable(list_table, labels, event)

      local button_table = frame.add {type = "flow", direction = "horizontal"}
      button_table.add {type = "button", name = "sponsor_list_table_add_new", caption = {mod_defines.gui.add_new}}
    end
  end,
  addItemsToListTable = function(self, list_table, entries, event)
    if not list_table then
      local player = game.players[event.player_index]
      local center_gui = player.gui.screen
      list_table = center_gui.sponsor_list.sponsor_list_scroll.sponsor_list_table
    end

    list_table.clear()
    local filtered = table.deepcopy(entries)
    filtered = self:applySearch(filtered, event)
    filtered = self:applySort(filtered, event)

    addSortHeader(list_table, "1", {mod_defines.gui.table_type}, event.player_index)
    addSortHeader(list_table, "2", {mod_defines.gui.table_name}, event.player_index)
    -- addSortHeader(list_table, "3", {mod_defines.gui.table_used}, event.player_index)

    list_table.add {
      type = "label",
      name = "sponsor_list_table_hused",
      caption = {mod_defines.gui.table_used},
      style = "bold_label"
    }

    list_table.add {
      type = "label",
      name = "sponsor_list_table_buttons",
      caption = {mod_defines.gui.table_action},
      style = "bold_label"
    }

    for index, label in pairs(filtered) do
      local is_used = mod_defines.gui.no
      if label.train ~= nil and label.train.valid then
        is_used = mod_defines.gui.yes
      end
      list_table.add {
        type = "label",
        name = "sponsor_list_table_ltype" .. index,
        caption = {mod_defines.prefix .. "_gui." .. label.sponsor_type}
      }
      list_table.add {type = "label", name = "sponsor_list_table_lname" .. index, caption = label.sponsor_name}
      list_table.add {type = "label", name = "sponsor_list_table_lused" .. index, caption = {is_used}}
      local button_flow = list_table.add {type = "flow", name = "sponsor_list_tablel_buttonflow" .. index}
      local button
      button =
        button_flow.add {
        type = "button",
        name = "sponsor_list_table_ledit" .. index,
        caption = {mod_defines.gui.edit}
      }
      button.style.height = 28
      button.style.top_padding = 0
      button.style.bottom_padding = 0
      button.style.minimal_width = 40

      button =
        button_flow.add {
        type = "button",
        name = "sponsor_list_table_ldelete" .. index,
        caption = {mod_defines.gui.delete}
      }
      button.style.height = 28
      button.style.top_padding = 0
      button.style.bottom_padding = 0
      button.style.minimal_width = 40
    end
  end,
  applySearch = function(self, list, event)
    local search = sort[event.player_index] and sort[event.player_index].search or nil
    if search then
      local result = {}
      for k, v in pairs(list) do
        if v.sponsor_name:match(search) then
          result[k] = v
        end
      end

      if (#result) then
        return result
      end
    end
    return list
  end,
  applySort = function(self, list, event)
    local idx = event.player_index
    if not sort[idx] or not sort[idx].sort or not sort[idx].sort.column then
      return list
    end

    local map = {
      [1] = "sponsor_type",
      [2] = "sponsor_name"
    }

    local sorting = sort[idx].sort
    local sort_column = map[sorting.column]
    local sort_dir = sorting.dir

    table.sort(
      list,
      function(a, b)
        if not a or not b then 
          return false
        end
        if a[sort_column] ~= b[sort_column] then
          if sort_dir == sort_order.desc then
            return a[sort_column] < b[sort_column]
          else
            return a[sort_column] > b[sort_column]
          end
        end
        return false
      end
    )
    return list
  end,
  clickSearchButton = function(self, event, index)
    local element = event.element
    local searchbar = element.parent.sponsor_list_search_field

    searchbar.visible = not searchbar.visible
  end,
  clickSortHeader = function(self, event, index)
    local element = event.element
    local player_index = event.player_index
    local cur = sort[player_index] and sort[player_index].sort or nil

    if sort[player_index] == nil then
      sort[player_index] = {
        search = "",
        sort = {}
      }
    end

    if cur and cur.column == index and cur.dir == sort_order.desc then
      cur.dir = sort_order.asc
    elseif cur and cur.column == index and cur.dir == sort_order.asc then
      sort[player_index].sort = {}
    else
      sort[player_index].sort = {column = index, dir = sort_order.desc}
    end

    self:addItemsToListTable(nil, mod_labels:get_labels(), event)
  end,
  clickEditButton = function(self, event, index)
    temp[event.player_index] = index
    self:clickAddButton(event, index)
  end,
  clickAddButton = function(self, event, index)
    -- open input dialog
    local player = game.players[event.player_index]
    local main_gui = player.gui.screen
    local center_gui = player.gui.center
    local label = mod_labels:get_label_by_index(index) or {}

    if main_gui.sponsor_list then
      main_gui.sponsor_list.destroy()
    end

    local frame = center_gui.add({type = "frame", name = "sponsor_list_add", direction = "vertical"})

    local options = mod_labels.get_config()
    options = self.mergeLabelToOptions(options, label)
    make_config_table(frame, options)
    local button_table = frame.add {type = "flow", direction = "horizontal"}
    button_table.add {type = "button", name = "sponsor_list_table_add_new_cancel", caption = {mod_defines.gui.cancel}}
    button_table.add {type = "button", name = "sponsor_list_table_add_new_save", caption = {mod_defines.gui.save}}
  end,
  mergeLabelToOptions = function(options, label)
    local res = options or {}
    if label then
      for i, v in pairs(options) do
        if type(v) == "table" and label[i] ~= nil then
          v.selected = label[i] or v.selected
        elseif type(v) == "boolean" then
          if label[i] ~= nil then
            v = not (not label[i])
          end
        else
          if label[i] ~= nil then
            v = label[i]
          end
        end
        res[i] = v
      end
    end
    return res
  end,
  clickCancelAddButton = function(self, event)
    self:closeAddFrame(event)
    self:clickListButton(event)
  end,
  clickSaveAddButton = function(self, event)
    -- store input
    local player = game.players[event.player_index]
    local center_gui = player.gui.center
    local frame = center_gui.sponsor_list_add
    local options = mod_labels.get_config()
    local values = parse_config_from_gui(frame, options)

    mod_labels:add_label(values, temp[event.player_index] or nil)
    self:closeAddFrame(event)
    self:clickListButton(event)
    global.storage = {}
    if temp[event.player_index] then
      temp[event.player_index] = nil
    end
  end,
  clickRemoveButton = function(self, event, index)
    index = tonumber(index)
    mod_labels:remove_label(index)
    -- double for open/close/refresh idea
    self:clickListButton(event)
    self:clickListButton(event)
  end,
  closeAddFrame = function(self, event)
    local player = game.players[event.player_index]
    local center_gui = player.gui.center
    if center_gui.sponsor_list_add then
      center_gui.sponsor_list_add.destroy()
    end
  end,
  openSelectWindow = function(self, event)
    local player = game.players[event.player_index]
    local center_gui = player.gui.center
    if center_gui.sponsor_list_apply then
      return false
    end
    local frame = center_gui.add({type = "frame", name = "sponsor_list_apply", direction = "vertical"})
    local options = {
      sponsor_type = mod_labels.get_config().sponsor_type
    }
    make_config_table(frame, options)
    local button_table = frame.add {type = "flow", direction = "horizontal"}
    button_table.add {type = "button", name = "sponsor_list_table_apply_cancel", caption = {mod_defines.gui.cancel}}
    button_table.add {type = "button", name = "sponsor_list_table_apply_save", caption = {mod_defines.gui.save}}
  end,
  clickConfirmSelectButton = function(self, event)
    local player = game.players[event.player_index]
    local center_gui = player.gui.center
    local frame = center_gui.sponsor_list_apply
    local options = {
      sponsor_type = mod_labels.get_config().sponsor_type
    }
    local values = parse_config_from_gui(frame, options)
    local label = mod_labels:get_unused_label(values.sponsor_type)

    if label then
      mod_labels:create_train_label(global.storage.entity.train, label)
    else
      game.print("Out of sponsors")
      local stor = global.storage
      if stor.inventory and stor.inventory.valid then
        stor.inventory.insert({name = stor.entity.name})
      end
      stor.entity.destroy()
    end
    self.closeSelectFrame(event)
    global.storage = {}
    if temp[event.player_index] then
      temp[event.player_index] = nil
    end
  end,
  clickCancelSelectButton = function(self, event)
    local stor = global.storage
    if stor.inventory and stor.inventory.valid then
      stor.inventory.insert({name = stor.entity.name})
    end
    stor.entity.destroy()
    self.closeSelectFrame(event)
    global.storage = {}
  end,
  closeSelectFrame = function(event)
    local player = game.players[event.player_index]
    local center_gui = player.gui.center
    if center_gui.sponsor_list_apply then
      center_gui.sponsor_list_apply.destroy()
    end
  end,
  returnEntityToPlayer = function(player, entity)
  end
}

return interface
