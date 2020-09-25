local base_util = require("util")
data.raw["utility-constants"]["default"].default_other_force_color = base_util.copy(data.raw["utility-constants"]["default"].default_enemy_force_color)


data:extend
{
  {
    type = "selection-tool",
    name = "AbandonedRuins-claim",
    icon = "__AbandonedRuins__/graphics/AbandonedRuins-claim.png",
    icon_size = 64,
    stack_size = 1,
    selection_color = {1, 1, 1},
    alt_selection_color = {1, 1, 1},
    selection_mode = {"buildable-type", "not-same-force", "friend"},
    alt_selection_mode = {"buildable-type", "not-same-force", "friend"},
    selection_cursor_box_type = "train-visualization",
    alt_selection_cursor_box_type = "train-visualization",
    always_include_tiles = true,
    flags = {"only-in-cursor"}
  },
  {
    type = "shortcut",
    name = "AbandonedRuins-claim",
    action = "create-blueprint-item",
    icon =
    {
      filename = "__AbandonedRuins__/graphics/AbandonedRuins-claim-shortcut.png",
      size = 32
    },
    item_to_create = "AbandonedRuins-claim",
    associated_control_input = "AbandonedRuins-claim"
  },
  {
    type = "custom-input",
    name = "AbandonedRuins-claim",
    key_sequence = "SHIFT + C",
    item_to_create = "AbandonedRuins-claim",
    action = "create-blueprint-item"
  }
}

