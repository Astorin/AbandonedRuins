local util = require("utilities")

local spawning = {}

local function no_corpse_fade(half_size, center, surface)
  local area = util.area_from_center_and_half_size(half_size, center)
  for _, entity in pairs(surface.find_entities_filtered({area = area, type={"corpse"}})) do
    entity.corpse_expires = false
  end
end

local function resolve_function_table_or_number(t)
  if type(t) == "table" then
    if t.type == "random" then
      return math.random(t.min, t.max)
    else
      error("unrecognized function type")
    end
  elseif type(t) == "number" then
    return t
  else
    error("received something that is not a number or table in resolve_function_table_or_number")
  end
end

local function spawn_entity(entity, relative_position, center, surface, extra_options, prototypes)
  if type(entity) == "table" then
    if entity.type == "random-of-entity-type" then
      local entities = {}
      for k in pairs(game.get_filtered_entity_prototypes({{filter = "type", type = entity.entity_type}})) do
        entities[#entities+1] = k
      end
      entity = entities[math.random(#entities)]
    else
      error("unrecognized function type")
    end
  end

  if not prototypes[entity] then
    util.debugprint("entity " .. entity .. " does not exist")
    return
  end

  local e = surface.create_entity
  {
    name = entity,
    position = {center.x + relative_position.x, center.y + relative_position.y},
    direction = defines.direction[extra_options.dir] or defines.direction.north,
    force = extra_options.force or "neutral",
    raise_built = true,
    create_build_effect_smoke = false,
    recipe = extra_options.recipe
  }

  if extra_options.dmg then
    extra_options.dmg.dmg = resolve_function_table_or_number(extra_options.dmg.dmg)
    util.safe_damage(e, extra_options.dmg)
  end
  if extra_options.items then
    local items = {}
    for name, count in pairs(extra_options.items) do
      items[name] = resolve_function_table_or_number(count)
    end
    util.safe_insert(e, items)
  end
end

local function spawn_entities(entities, center, surface)
  if not entities then return end

  local prototypes = game.entity_prototypes

  for _, entity_info in pairs(entities) do
    spawn_entity(entity_info[1], entity_info[2], center, surface, entity_info[3], prototypes)
  end
end

local function spawn_tiles(tiles, center, surface)
  if not tiles then return end

  local prototypes = game.tile_prototypes
  local valid = {}
  for _, tile_info in pairs(tiles) do
    local name = tile_info[1]
    local pos = tile_info[2]
    if prototypes[name] then
      valid[#valid+1] = {name = name, position = {center.x + pos.x, center.y + pos.y}}
    else
      util.debugprint("tile " .. name .. " does not exist")
    end
  end

  surface.set_tiles(
    valid,
    true, -- correct_tiles,                Default: true
    true, -- remove_colliding_entities,    Default: true
    true, -- remove_colliding_decoratives, Default: true
    true) -- raise_event,                  Default: false
end

local function clear_area(half_size, center, surface)
  local area = util.area_from_center_and_half_size(half_size, center)
  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = {"item-layer", "object-layer"} } == 1 then
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type={"resource", "tree"}, invert = true})) do
    entity.destroy({do_cliff_correction = true, raise_destroy = true})
  end

  return true
end

spawning.spawn_ruin = function(ruin, half_size, center, surface)
  if clear_area(half_size, center, surface) then
    spawn_entities(ruin.entities, center, surface)
    spawn_tiles(ruin.tiles, center, surface)
    no_corpse_fade(half_size, center, surface)
  end
end

spawning.spawn_random_ruin = function(ruins, half_size, center, surface)
  --spawn a random ruin from the list
  spawning.spawn_ruin(ruins[math.random(#ruins)], half_size, center, surface)
end

return spawning