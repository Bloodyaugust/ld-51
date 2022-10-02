extends KinematicBody2D

export var data_default: Resource

var health: int
var data: UnitData

onready var _player: Node2D = get_tree().get_nodes_in_group("player")[0]

var _health: int
var _time_to_attack: float

func hit(damage: int) -> void:
  _health -= damage

  if _health <= 0:
    kill()

func kill() -> void:
  queue_free()

func _attack(player: Node2D) -> void:
  player.hit(data.damage)
  _time_to_attack = data.attack_interval

func _physics_process(_delta: float) -> void:
  if !GDUtil.reference_safe(_player):
    kill()
    return

  var _direction: Vector2 = global_position.direction_to(_player.global_position)
  var _movement: Vector2 = _direction * data.speed

  move_and_slide(_movement)

  if _time_to_attack <= 0:
    for _i in get_slide_count():
      var _collision: KinematicCollision2D = get_slide_collision(_i)
      var _colliding_object: Node = _collision.collider as Node

      if !_colliding_object.is_in_group("enemies") && _colliding_object.has_method("hit"):
        _attack(_colliding_object)

func _process(delta: float) -> void:
  _time_to_attack -= delta

func _ready() -> void:
  if !data:
    data = data_default

  _health = data.health
