class_name Formulas 
extends Reference

static func calculate_potential_damage(action_data, attacker) -> float:
  return attacker.stats.attack * action_data.damage_multiplier

static func calculate_base_damage(action_data, attacker, defender) -> int:
  var damage: float = calculate_potential_damage(action_data, attacker)
  damage -= defender.stats.defence
  damage *= _calculate_weakness_multiplier(action_data, defender)
  return int(clamp(damage, 1.0, 999.0)) 

static func _calculate_weakness_multiplier(action_data, defender) -> float:
  var multiplier := 1.0 
  var element: int = action_data.element
  if element != Types.Elements.NONE:
    if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
      multiplier = 0.75 
    elif Types.WEAKNESS_MAPPING[element] in defender.stats.weaknesses:
      multiplier = 1.5 
  return multiplier

static func calculate_hit_chance(action_data, attacker, defender) -> float:
  var chance: float = attacker.stats.hit_chance - defender.stats.evasion
  var element: int = action_data.element 
  chance *= action_data.hit_chance / 100.0 
  if element == attacker.stats.affinity:
    chance += 5.0 
  if element != Types.Elements.NONE:
    if Types.WEAKNESS_MAPPING[element] in defender.stats.weaknesses:
      chance += 10.0 
    if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
      chance -= 10.0 
  return clamp(chance, 0.0, 100.0)
