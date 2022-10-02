extends KinematicBody2D

signal died

const MOVE_SPEED_BASE: float = 25.0
const OXYGEN_CAPACITY_BASE: int = 6
const WEAPON_SCRIPT := preload("res://scripts/weapon.gd")
const OXYGEN_USE_INTERVAL: float = 10.0

var last_move_direction: Vector2 = Vector2.RIGHT
var oxygen_capacity: int = OXYGEN_CAPACITY_BASE
var oxygen_interval: float = OXYGEN_USE_INTERVAL

onready var _animated_sprite: AnimatedSprite = $"%AnimatedSprite"

var _oxygen: int

func hit(damage: int) -> void:
  _oxygen -= damage
  if _oxygen <= 0:
    _die()

func _die() -> void:
  emit_signal("died")
  queue_free()

func _on_weapon_changed(weapon_data: WeaponData, _weapon_level: int) -> void:
  var new_weapon := WEAPON_SCRIPT.new()
  new_weapon.data = weapon_data
  new_weapon.player = self
  add_child(new_weapon)
  
func _process(delta):
  var _movement: Vector2 = Vector2.ZERO
  
  _movement += Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized() * MOVE_SPEED_BASE
  
  oxygen_interval -= delta
  
  if oxygen_interval <= 0:
    hit(1)
    oxygen_interval = OXYGEN_USE_INTERVAL
  
  if _movement.normalized().length() > 0.1:
    last_move_direction = _movement.normalized()
    _animated_sprite.playing = true
    _animated_sprite.flip_h = last_move_direction.x >= 0
  else:
    _animated_sprite.playing = false
  
  move_and_slide(_movement)

func _ready() -> void:
  Store.connect("weapon_changed", self, "_on_weapon_changed")

  _oxygen = oxygen_capacity
