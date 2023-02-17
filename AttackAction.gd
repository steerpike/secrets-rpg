class_name AttackAction
extends Action 

var _hits := []

func _init(data: AttackActionData, actor, targets: Array).(data, actor, targets) -> void:
  pass

func calculate_potential_damage_for(target) -> int:
  return Formulas.calculate_base_damage(_data, _actor, target)

func _apply_async() -> bool:
  for target in _targets:
    if target is Array and not target.empty():
      target = target[0]
    var hit_chance := Formulas.calculate_hit_chance(_data, _actor, target)
    var damage := calculate_potential_damage_for(target)
    var hit := Hit.new(damage, hit_chance)
    target.take_hit(hit)
  yield(Engine.get_main_loop(), "idle_frame")
  return true