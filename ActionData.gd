class_name ActionData 
extends Resource

enum Elements { NONE, CODE, DESIGN, ART, BUG }

export var icon: Texture
export var label := "Base combat action"
export var energy_cost := 0
export (Elements) var element := Elements.NONE
export var is_targeting_self := false 
export var is_targeting_all := false
export var readiness_saved := 0.0

func can_be_used_by(battler) -> bool:
  return energy_cost <= battler.stats.energy
