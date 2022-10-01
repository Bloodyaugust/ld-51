extends KinematicBody2D

export var data_default: Resource

var health: int
var data: UnitData

onready var _player: Node2D = get_tree().get_nodes_in_group("player")[0]

var _time_to_attack: float

func hit() -> void:
  data.health -= 1
  if data.health <= 0:
    kill()
    
func kill() -> void:
  queue_free()

func _physics_process(_delta: float) -> void:
  var _direction: Vector2 = global_position.direction_to(_player.global_position)
  var _movement: Vector2 = _direction * data.speed

  move_and_slide(_movement)
  
func _ready() -> void:
  if !data:
    data = data_default
