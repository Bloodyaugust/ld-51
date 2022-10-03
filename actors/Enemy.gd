extends KinematicBody2D

export var data_default: Resource

var health: int
var data: UnitData

onready var _player: Node2D = get_tree().get_nodes_in_group("player")[0]
onready var _sprite: Sprite = $"%Sprite"

var _dead: bool = false
var _health: int
var _time_to_attack: float
var _attacked_this_frame: bool
var _target_direction: Vector2

func hit(damage: int) -> void:
  _health -= damage

  if _health <= 0 && !_dead:
    kill()

func kill() -> void:
  _dead = true
  DropController.drop(global_position)
  Store.set_state("enemies_killed", Store.state.enemies_killed + 1)
  queue_free()

func _attack(player: Node2D) -> void:
  _attacked_this_frame = true
  player.hit(data.damage)
  _time_to_attack = data.attack_interval

func _physics_process(_delta: float) -> void:
  _attacked_this_frame = false
  if !GDUtil.reference_safe(_player):
    _dead = true
    queue_free()
    return

  var _direction: Vector2 = Vector2.RIGHT
  var _movement: Vector2 = Vector2.ZERO

  if "target_indifferent" in data.flags:
    _direction = _target_direction
    _movement = _direction * data.speed

  if "tracking" in data.flags:
    _direction = global_position.direction_to(_player.global_position)
    _movement = _direction * data.speed

  move_and_slide(_movement)
  
  _sprite.flip_h = _movement.x >= 0

  if _time_to_attack <= 0:
    for _i in get_slide_count():
      if !_attacked_this_frame:
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

  if "target_indifferent" in data.flags:
    _target_direction = global_position.direction_to(_player.global_position)
