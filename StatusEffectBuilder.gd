class_name StatusEffectBuilder
extends Reference

const StatusEffects := { 
  haste = StatusEffectHaste,
  slow = StatusEffectSlow,
  poison = StatusEffectPoison,
}

static func create_status_effect(target, data):
  if not data:
      return null
  var effect_class = StatusEffects[data.effect]
  var effect: StatusEffect = effect_class.new(target, data)
  return effect
