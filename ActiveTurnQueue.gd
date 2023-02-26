class_name ActiveTurnQueue
extends Node2D

var _party_members := []
var _opponents := []
var is_active := true setget set_is_active
var time_scale := 1.0 setget set_time_scale
var _is_player_playing := false
var _queue_player := []

onready var battlers := get_children()

signal player_turn_finished

func _ready() -> void:
    for battler in battlers:
        battler.setup(battlers)
        battler.connect("ready_to_act", self, "_on_Battler_ready_to_act", [battler])
        connect("player_turn_finished", self, "_on_player_turn_finished")
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
    if battler.is_player_controlled() and _is_player_playing:
      _queue_player.append(battler)
    else:
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
      _is_player_playing = true
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
      var result: Dictionary = battler.get_ai().choose()
      action_data = result.action
      targets = result.targets
      print("%s attacks %s with action %s" % [battler.name, targets[0].name, action_data.label])
    var action = AttackAction.new(action_data, battler, targets)
    battler.act(action)
    if battler.is_player_controlled():
      emit_signal("player_turn_finished")
    yield(battler, "action_finished")

func _player_select_action_async(battler: Battler) -> ActionData:
    yield(get_tree(), "idle_frame")
    return battler.actions[0]
    
func _player_select_targets_async(_action: ActionData, opponents: Array) -> Array:
    yield(get_tree(), "idle_frame")
    if not opponents.empty():
      return [opponents[0]]
    return []

func _on_player_turn_finished() -> void:
  if _queue_player.empty():
    _is_player_playing = false
  else:
    _play_turn(_queue_player.pop_front())
