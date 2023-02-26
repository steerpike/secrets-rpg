class_name AttackAction
extends Action 

var StatusEffectBuilder = load("res://StatusEffectBuilder.gd")
var _hits := []

func _init(data: AttackActionData, actor, targets: Array).(data, actor, targets) -> void:
  pass

func calculate_potential_damage_for(target) -> int:
  return Formulas.calculate_base_damage(_data, _actor, target)

func _apply_async() -> bool:
  var anim = _actor.battler_anim
  for target in _targets:
    if target is Array and not target.empty():
      target = target[0]
    var hit_chance := Formulas.calculate_hit_chance(_data, _actor, target)
    var damage := calculate_potential_damage_for(target)
    var status: StatusEffect = StatusEffectBuilder.create_status_effect(target, _data.status_effect) 
    var hit := Hit.new(damage, hit_chance, status)
    #target.take_hit(hit)
    anim.connect("triggered", self, "_on_BattlerAnim_triggered", [target, hit])
    anim.play("attack")
    yield(_actor, "animation_finished")
    print("Yield done, animation finished")
  #yield(Engine.get_main_loop(), "idle_frame")
  return true

func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
  target.take_hit(hit)
