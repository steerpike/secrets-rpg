class_name ActiveTurnQueue
extends Node2D

var _party_members := []
var _opponents := []
var is_active := true setget set_is_active
var time_scale := 1.0 setget set_time_scale

onready var battlers := get_children()

func _ready() -> void:
    for battler in battlers:
        battler.connect("ready_to_act", self, "_on_Battler_ready_to_act", [battler])
        if battler.is_party_member:
            _party_members.append(battler)
        else:
            _opponents.append(battler)

func set_is_active(value: bool) -> void:
    is_active = value
    for battler in battlers:
        battler.is_active = is_active

func set_time_scale(value: float) -> void:
    time_scale = value
    for battler in battlers:
        battler.time_scale = time_scale

func _on_Battler_ready_to_act(battler: Battler) -> void:
    _play_turn(battler)

func _play_turn(battler: Battler) -> void:
    var action_data: ActionData
    var targets := []
    var potential_targets := []
    var is_selection_complete := false
    var opponents := _opponents if battler.is_party_member else _party_members
    battler.stats.energy += 1
    for opponent in opponents:
        if opponent.is_selectable:
            potential_targets.append(opponents)
    if battler.is_player_controlled():
        battler.is_selected = true
        set_time_scale(0.05)
        while not is_selection_complete:
            action_data = yield(_player_select_action_async(battler), "completed")
            if action_data.is_targeting_self:
                targets = [battler]
            else:
                targets = yield(_player_select_targets_async(action_data, potential_targets), "completed")
            is_selection_complete = action_data != null && targets != []
        set_time_scale(1.0)
        battler.is_selected  = false
    else:
        action_data = battler.actions[0]
        targets = [potential_targets[0]]
    var action = AttackAction.new(action_data, battler, targets)
    battler.act(action)
    yield(battler, "action_finished")

func _player_select_action_async(battler: Battler) -> ActionData:
    yield(get_tree(), "idle_frame")
    return battler.actions[0]
    
func _player_select_targets_async(_action: ActionData, opponents: Array) -> Array:
    yield(get_tree(), "idle_frame")
    return [opponents[0]]
