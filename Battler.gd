extends Node2D
class_name Battler

export var stats: Resource
export var ai_scene: PackedScene
export var actions: Array
export var is_party_member := false
export var ui_data: Resource

var time_scale := 1.0 setget set_time_scale
var _readiness := 0.0 setget _set_readiness
var is_active: bool = true setget set_is_active
var is_selected: bool = false setget set_is_selected
var is_selectable: bool = true setget set_is_selectable
var _ai_instance = null
var _status_effect_container := StatusEffectContainer.new()
onready var battler_anim: BattlerAnim = $BattlerAnim
onready var _status_container: StatusEffectContainer = $StatusEffectContainer


signal ready_to_act
signal readiness_changed(new_value)
signal selection_toggled(value)
signal damage_taken(amount)
signal hit_missed
signal action_finished
signal animation_finished(anim_name)

func setup(battlers: Array) -> void:
  if ai_scene:
    _ai_instance = ai_scene.instance()
    _ai_instance.setup(self, battlers)
    add_child(_ai_instance)

func _ready() -> void:
    assert(stats is BattlerStats)
    stats = stats.duplicate()
    stats.reinitialize()
    stats.connect("health_depleted", self, "_on_BattleStats_health_depleted")
    battler_anim.connect("animation_finished", self, "_on_BattlerAnim_animation_finished")
    add_child(_status_effect_container)

func _set_readiness(value) -> void:
    _readiness = value
    emit_signal("readiness_changed", _readiness)
    if _readiness >= 100.0:
        emit_signal("ready_to_act")
        set_process(false) 

func set_time_scale(value) -> void:
    time_scale = value
    _status_container.time_scale = time_scale

func set_is_active(value: bool) -> void:
    is_active = value
    _status_container.is_active = value
    set_process(is_active)

func set_is_selected(value) -> void:
    if value:
        assert(is_selectable)
    is_selected = value
    if is_selected:
        battler_anim.move_up()
    emit_signal("selection_toggled", is_selected)

func set_is_selectable(value) -> void:
    is_selectable = value
    if not is_selectable:
        set_is_selected(false)

func is_player_controlled() -> bool:
    return ai_scene == null

func _process(delta: float) -> void:
    _set_readiness(_readiness + stats.speed * delta * time_scale)
    
func _on_BattleStats_health_depleted() -> void:
    set_is_active(false)
    if not is_party_member:
        set_is_selectable(false)
        battler_anim.queue_animation("die")

func take_hit(hit: Hit) -> void:
    if hit.does_hit():
        _take_damage(hit.damage)
        emit_signal("damage_taken", hit.damage)
        if hit.effect:
            _apply_status_effect(hit.effect)
    else:
        emit_signal("hit_missed")

func _take_damage(amount: int) -> void:
    stats.health -= amount
    if stats.health > 0:
        battler_anim.play("take_damage")
    print("%s took %s damage. Health is now %s." % [name, amount, stats.health])

func act(action) -> void:
    stats.energy -= action.get_energy_cost()
    battler_anim.move_down()
    yield(action.apply_async(), "completed")
    _set_readiness(action.get_readiness_saved())
    if is_active:
        set_process(true)
    emit_signal("action_finished")

func _apply_status_effect(effect) -> void:
    _status_container.add(effect)
    print("Applying effect %s to %s" % [effect.id, name])

func _on_BattlerAnim_animation_finished(anim_name):
  emit_signal("animation_finished", anim_name)

func is_fallen() -> bool:
  return stats.health == 0

func get_ai() -> Node:
    return _ai_instance
