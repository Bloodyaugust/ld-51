extends KinematicBody2D

const MOVE_SPEED_BASE: float = 25.0
const OXYGEN_CAPACITY_BASE: int = 6
const WEAPON_SCRIPT := preload("res://scripts/weapon.gd")
const OXYGEN_USE_INTERVAL: float = 10.0

var last_move_direction: Vector2 = Vector2.RIGHT
var oxygen_capacity: int = OXYGEN_CAPACITY_BASE
var oxygen_interval: float = OXYGEN_USE_INTERVAL

var _oxygen: int

func hit(damage: int) -> void:
  _oxygen -= damage
  
  if _oxygen <= 0:
    _die()

func _die() -> void:
  queue_free()

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "weapons":
      var new_weapon := WEAPON_SCRIPT.new()
      new_weapon.data = substate[0]
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
  
  move_and_slide(_movement)

func _ready() -> void:
  Store.connect("state_changed", self, "_on_store_state_changed")

  _oxygen = oxygen_capacity
