extends Resource
class_name BattlerStats

signal health_depleted
signal health_changed(old_value, new_value)
signal energy_changed(old_value, new_value)

export var max_health := 100.0 
export var max_energy : = 6
export var base_attack := 10.0 setget set_base_attack
export var base_defence := 10.0 setget set_base_defence
export var base_speed := 70.0 setget set_base_speed
export var base_hit_chance := 100.0 setget set_base_hit_chance
export var base_evasion := 0.0 setget set_base_evasion
export var weaknesses := []
export (Types.Elements) var affinity: int = Types.Elements.NONE

const UPGRADABLE_STATS = [
	"max_health", "max_energy", "attack", "defence", "speed", "hit_chance", "evasion"
]

var health := max_health setget set_health 
var energy := 0 setget set_energy 
var attack := base_attack
var defence := base_defence
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

var _modifiers = {}

func _init() -> void:
  for stat in UPGRADABLE_STATS:
    _modifiers[stat] = {
      value = {},
      rate = {}
    }

func set_base_attack(value) -> void:
  base_attack = value
  _recalculate_and_update("attack")

func set_base_defence(value) -> void:
  base_defence = value
  _recalculate_and_update("defence")

func set_base_speed(value) -> void:
  base_speed = value
  _recalculate_and_update("speed")

func set_base_hit_chance(value) -> void:
  base_hit_chance = value
  _recalculate_and_update("hit_chance")

func set_base_evasion(value) -> void:
  base_evasion = value
  _recalculate_and_update("evasion")

func reinitialize() -> void:
  set_health(max_health)

func set_health(value: float) -> void:
  var health_previous := health 
  health = clamp(value, 0.0, max_health)
  emit_signal("health_changed", health_previous, health)
  if is_equal_approx(health, 0.0):
    emit_signal("health_depleted")

func set_energy(value: int) -> void:
  var energy_previous := energy 
  energy = int(clamp(value, 0.0, max_energy))
  emit_signal("energy_changed", energy_previous, energy)

func _recalculate_and_update(stat: String) -> void:
  var value: float = get("base_"+str(stat))
  var modifiers_multiplier: Array = _modifiers[stat]["rate"].values()
  var modifiers_value: Array = _modifiers[stat]["value"].values()
  var multiplier := 1.0 
  for modifier in modifiers_multiplier:
    multiplier += modifier 
  if not is_equal_approx(multiplier, 1.0):
    value *= multiplier
  for modifier in modifiers_value:
    value += modifier
  
  value = round(max(value, 0.0))
  set(stat, value)

func add_value_modifier(stat_name: String, value: float) -> void:
  _add_modifier(stat_name, value, 0.0)

func add_rate_modifier(stat_name: String, rate: float) -> void:
  _add_modifier(stat_name, 0.0, rate)

func _add_modifier(stat_name: String, value: float, rate := 0.0) -> int:
  assert(stat_name in UPGRADABLE_STATS, "Trying to modify a nonexistent stat")
  var id := -1
  if not is_equal_approx(value, 0.0):
    id = _generate_unique_id(stat_name, true)
    _modifiers[stat_name]["value"][id] = value
  if not is_equal_approx(rate, 0.0):
    id = _generate_unique_id(stat_name, false)
    _modifiers[stat_name]["rate"][id] = rate

  _recalculate_and_update(stat_name)
  return id 

func remove_modifier(stat_name: String, id: int) -> void:
  assert(id in _modifiers[stat_name], "Id %s not found in %s" % [id, _modifiers[stat_name]])
  _modifiers[stat_name].erase(id)
  _recalculate_and_update(stat_name)

func _generate_unique_id(stat_name: String, is_value_modifier: bool) -> int:
  var type := "value" if is_value_modifier else "rate"
  var keys: Array = _modifiers[stat_name][type].keys()
  if keys.empty():
    return 0;
  else:
    return keys.back() + 1

