tool
class_name BattlerAnim
extends Position2D

signal animation_finished(name)
signal triggered

enum Direction { UP, DOWN }

export (Direction) var direction := Direction.UP setget set_direction

var _position_start := Vector2.ZERO

onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
onready var anim_player_damage: AnimationPlayer = $Pivot/AnimationPlayerDamage
onready var tween: Tween = $Tween

func set_direction(value):
    direction = value
    scale.y = -1.0 if direction == Direction.DOWN else 1.0

func _ready() -> void:
    _position_start = position
    anim_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
    anim_player_damage.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

func play(anim_name: String) -> void:
    if anim_name == "take_damage":
        anim_player_damage.play(anim_name)
        anim_player_damage.seek(0.0)
    else:
        anim_player.play(anim_name)

func is_playing() -> bool:
  return anim_player.is_playing()
    
func queue_animation(anim_name: String) -> void:
  anim_player.queue(anim_name)
  if not anim_player.is_playing():
    anim_player.play()

func move_up() -> void:
  tween.interpolate_property(
    self, 
    "position",
    position,
    position + Vector2.UP * scale.y * 40.0,
    0.3,
    Tween.TRANS_QUART,
    Tween.EASE_IN_OUT
    )
  tween.start()
    
func move_down() -> void:
  tween.interpolate_property(
    self, "position", position, _position_start, 0.3, Tween.TRANS_QUART, Tween.EASE_IN_OUT
    )
  tween.start()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
  emit_signal("animation_finished", anim_name)

