class_name Action
extends Reference 

signal finished 

var _data: ActionData
var _actor
var _targets := []

func _init(data: ActionData, actor, targets: Array) -> void:
  _data = data
  _actor = actor 
  _targets = targets

func apply_async() -> bool:
  return _apply_async()

func _apply_async() -> bool:
  emit_signal("finished")
  return true

func targets_opponents() -> bool:
  return true

func get_readiness_saved() -> float:
  return _data.readiness_saved 

func get_energy_cost() -> int:
  return _data.energy_cost