extends Node

var data: WeaponData

var _time_to_fire: float

func _fire() -> void:
  print("pew pew")

func _process(delta: float) -> void:
  _time_to_fire -= delta
  
  if _time_to_fire <= 0:
    _time_to_fire = data.fire_interval
    _fire()
      
func _ready() -> void:
  _time_to_fire = data.fire_interval
