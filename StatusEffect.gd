class_name StatusEffect
extends Node

var time_scale := 1.0
var duration_seconds := 0.0 setget set_duration_seconds
var is_ticking := false
var ticking_interval := 1.0
var is_active := true setget set_is_active
var id := "base_effect"
var _time_left: float = -INF
var _ticking_clock := 0.0
var _can_stack := false
var _target

func _ready() -> void:
  _start()
  
func _process(delta: float) -> void:
  _time_left -= delta * time_scale
  if is_ticking:
    var old_clock = _ticking_clock
    _ticking_clock = wrapf(_ticking_clock - delta * time_scale, 0.0, ticking_interval)
    if _ticking_clock > old_clock:
      _apply()
    if _time_left < 0.0:
      set_process(false)
      _expire()

func _start() -> void:
  pass
  
func expire() -> void:
  pass

func _expire() -> void:
  queue_free()
  
func _apply() -> void:
  pass

func _init(target, data) -> void:
  _target = target
  set_duration_seconds(data.duration_seconds)
  is_ticking = data.is_ticking
  ticking_interval = data.ticking_interval
  _ticking_clock = ticking_interval

func set_is_active(value) -> void:
  is_active = value
  set_process(is_active)

func set_duration_seconds(value: float) -> void:
  duration_seconds = value
  _time_left = duration_seconds

func can_stack() -> bool:
  return _can_stack

func get_time_left() -> float:
  return _time_left
