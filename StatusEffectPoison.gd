class_name StatusEffectPoison
extends StatusEffect

var damage := 3

func _init(target, data).(target, data) -> void:
  id = "poison"
  damage = data.ticking_damage
  _can_stack = true

func _apply() -> void:
  _target.take_hit(Hit.new(damage))
