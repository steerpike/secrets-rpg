extends Node2D
class_name Battler

export var stats: Resource
export var ai_scene: PackedScene
export var actions: Array
export var is_party_member := false

var time_scale := 1.0 setget set_time_scale
var _readiness := 0.0 setget _set_readiness
var is_active: bool = true setget set_is_active
var is_selected: bool = false setget set_is_selected
var is_selectable: bool = true setget set_is_selectable

signal ready_to_act
signal readiness_changed(new_value)
signal selection_toggled(value)
signal damage_taken(amount)
signal hit_missed
signal action_finished

func _ready() -> void:
    assert(stats is BattlerStats)
    stats = stats.duplicate()
    stats.reinitialize()
    stats.connect("health_depleted", self, "_on_BattleStats_health_depleted")

func _set_readiness(value) -> void:
    _readiness = value
    emit_signal("readiness_changed", _readiness)
    if _readiness >= 100.0:
        emit_signal("ready_to_act")
        set_process(false)
    
func set_time_scale(value) -> void:
    time_scale = value

func set_is_active(value: bool) -> void:
    is_active = value
    set_process(is_active)

func set_is_selected(value) -> void:
    if value:
        assert(is_selectable)
    is_selected = value
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

func take_hit(hit: Hit) -> void:
    if hit.does_hit():
        _take_damage(hit.damage)
        emit_signal("damage_taken", hit.damage)
    else:
        emit_signal("hit_missed")

func _take_damage(amount: int) -> void:
    stats.health -= amount
    print("%s took %s damage. Health is now %s." % [name, amount, stats.health])

func act(action) -> void:
    stats.energy -= action.get_energy_cost()
    yield(action.apply_async(), "completed")
    _set_readiness(action.get_readiness_saved())
    if is_active:
        set_process(true)
    emit_signal("action_finished")
