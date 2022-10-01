extends Node2D

export var data_default: Resource

var health: int
var data: UnitData

onready var _player: Node2D = get_tree().get_nodes_in_group("player")[0]

var _time_to_attack: float

func _process(delta: float) -> void:
  var _direction: Vector2 = global_position.direction_to(_player.global_position)
  
  global_position += _direction * data.speed * delta
  
  
func _ready() -> void:
  if !data:
    data = data_default
