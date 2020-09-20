data:extend({
  {
    type = "bool-setting",
    name = "AbandonedRuins-enemy-not-cease-fire",
    setting_type = "runtime-global",
    default_value = true,
    order = "a",
  },
  {
    type = "int-setting",
    name = "ruins-min-distance-from-spawn",
    setting_type = "runtime-global",
    default_value = 200,
    order = "ab",
  },
  {
    type = "double-setting",
    name = "ruins-large-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.005,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "d",
  },
  {
    type = "double-setting",
    name = "ruins-medium-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.02,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "c",
  },
  {
    type = "double-setting",
    name = "ruins-small-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.05,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "b",
  }
})
