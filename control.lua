local util = require("utilities")
local spawning = require("spawning")
local ruin_sets = {}
ruin_sets.base = require("ruins/base_ruin_set")

local function spawn_chances()
  local smallChance = settings.global["ruins-small-ruin-chance"].value
  local mediumChance = settings.global["ruins-medium-ruin-chance"].value
  local largeChance = settings.global["ruins-large-ruin-chance"].value
  local sumChance = smallChance + mediumChance + largeChance
  local totalChance = math.min(sumChance, 1)
  -- now compute cumulative distribution of conditional probabilities for
  -- spawn_type given a spawn occurs.
  local smallThreshold = smallChance / sumChance * totalChance
  local mediumThreshold = mediumChance / sumChance * totalChance + smallThreshold
  local largeThreshold = largeChance / sumChance * totalChance + mediumThreshold

  global.spawn_table = {small = smallThreshold, medium = mediumThreshold, large = largeThreshold}
end

local function init()
  util.set_enemy_force_cease_fire(util.get_enemy_force(), not settings.global["AbandonedRuins-enemy-not-cease-fire"].value)
  spawn_chances()
  if global.spawn_ruins == nil then
    global.spawn_ruins = true
  end
  global.excluded_surfaces = global.excluded_surfaces or {}
  global.excluded_surfaces["beltlayer"] = true
  global.excluded_surfaces["pipelayer"] = true
  global.excluded_surfaces["Factory floor"] = true -- factorissimo
  global.excluded_surfaces["ControlRoom"] = true -- mobile factory
end

script.on_init(init)
script.on_configuration_changed(init)
script.on_event(defines.events.on_runtime_mod_setting_changed, init)

local function spawn_ruin(size, center, surface)
  spawning.spawn_random_ruin(ruin_sets[settings.global["AbandonedRuins-set"].value][size], util.ruin_half_sizes[size], center, surface)
end

script.on_event(defines.events.on_chunk_generated,
  function (e)
    if util.str_contains_any_from_table(e.surface.name, global.excluded_surfaces) then return end

    if global.spawn_ruins == false then return end -- ruin spawning is disabled

    local center = util.get_center_of_chunk(e.position)
    if math.abs(center.x) < settings.global["ruins-min-distance-from-spawn"].value and math.abs(center.y) < settings.global["ruins-min-distance-from-spawn"].value then return end --too close to spawn

    local spawn_type = math.random()
    if spawn_type <= global.spawn_table.small then --spawn small ruin
      --random variance so they aren't always chunk aligned
      center.x = center.x + math.random(-10,10)
      center.y = center.y + math.random(-10,10)

      spawn_ruin("small", center, e.surface)
    elseif spawn_type <= global.spawn_table.medium then --spawn medium ruin
      --random variance so they aren't always chunk aligned
      center.x = center.x + math.random(-5,5)
      center.y = center.y + math.random(-5,5)

      spawn_ruin("medium", center, e.surface)
    elseif spawn_type <= global.spawn_table.large then --spawn large ruin
      spawn_ruin("large", center, e.surface)
    end
  end
)

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, function(event)
  if event.item ~= "AbandonedRuins-claim" then return end
  for _, entity in pairs(event.entities) do
    if entity.force.name == "neutral" then
      entity.force = game.get_player(event.player_index).force
    end
  end
end)

remote.add_interface("AbandonedRuins",
{
  -- Set whether ruins should be spawned at all
  set_spawn_ruins = function(spawn_ruins)
    if type(spawn_ruins) ~= "boolean" then
      error("Remote call parameter to set_spawn_ruins for AbandonedRuins must be a boolean value.")
    end
    global.spawn_ruins = spawn_ruins
  end,

  -- Get whether ruins should be spawned at all
  get_spawn_ruins = function() return global.spawn_ruins end,

  -- Any surface whose name contains this string will not have ruins generated on it.
  exclude_surface = function(name)
    if type(name) ~= "string" then
      error("Remote call parameter to exclude_surface for AbandonedRuins must be a string value.")
    end
    global.excluded_surfaces[name] = true
  end,

  -- You excluded a surface at some earlier point but you don't want it excluded anymore.
  reinclude_surface = function(name)
    if type(name) ~= "string" then
      error("Remote call parameter to reinclude_surface for AbandonedRuins must be a string value.")
    end
    global.excluded_surfaces[name] = nil
  end,

  -- !! ALWAYS call this in on_load and on_init. !!
  -- !! The ruins sets are not save/loaded. !!
  -- small_ruins, medium_ruins and large_ruins are each arrays of ruins.
  -- The ruins should have the sizes given in util.ruin_half_sizes, e.g. ruins in the small_ruins array should be 8x8 tiles.
  -- See also: docs/ruin_sets.md
  add_ruin_set = function(name, small_ruins, medium_ruins, large_ruins)
    assert(small_ruins and next(small_ruins))
    assert(medium_ruins and next(medium_ruins))
    assert(large_ruins and next(large_ruins))

    ruin_sets[name] = {}
    ruin_sets[name].small = small_ruins
    ruin_sets[name].medium = medium_ruins
    ruin_sets[name].large = large_ruins
  end,

  -- !! The ruins sets are not save/loaded. !!
  -- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
  get_ruin_set = function(name)
    return ruin_sets[name]
  end,

  -- !! The ruins sets are not save/loaded. !!
  -- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
  get_current_ruin_set = function()
    return ruin_sets[settings.global["AbandonedRuins-set"].value]
  end
})
