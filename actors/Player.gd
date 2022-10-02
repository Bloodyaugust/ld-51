extends KinematicBody2D

signal died
signal oxygen_changed(oxygen)

const MOVE_SPEED_BASE: float = 50.0
const OXYGEN_CAPACITY_BASE: int = 6
const WEAPON_SCRIPT := preload("res://scripts/weapon.gd")
const OXYGEN_USE_INTERVAL: float = 10.0
const JETPACK_FUEL_PER_SECOND: float = 1.0
const ESCAPE_JETPACK_FUEL: float = 5.0

var last_move_direction: Vector2 = Vector2.RIGHT
var oxygen: int
var oxygen_capacity: int = OXYGEN_CAPACITY_BASE
var oxygen_interval: float = OXYGEN_USE_INTERVAL
var jetpack_fuel: float = 0.0
var can_escape: bool = false

onready var _animated_sprite: AnimatedSprite = $"%AnimatedSprite"
onready var _animation_player: AnimationPlayer = $"%AnimationPlayer"
onready var _background: Sprite = get_tree().get_nodes_in_group("background")[0]
onready var _camera: Camera2D = get_tree().get_nodes_in_group("camera")[0]

func hit(damage: int) -> void:
  oxygen -= damage
  emit_signal("oxygen_changed", oxygen)
  if oxygen <= 0:
    _die()

func start_upgrade() -> void:
  Store.set_state("game", GameConstants.GAME_TRANSITIONING)

func _die() -> void:
  emit_signal("died")
  queue_free()

func _on_weapon_changed(weapon_data: WeaponData, _weapon_level: int) -> void:
  var new_weapon := WEAPON_SCRIPT.new()
  new_weapon.data = weapon_data
  new_weapon.player = self
  new_weapon.pause_mode = Node.PAUSE_MODE_STOP
  add_child(new_weapon)
  
func _process(delta):
  if Store.state.game == GameConstants.GAME_ESCAPING:
    return
    
  var _movement: Vector2 = Vector2.ZERO
  
  jetpack_fuel += delta * JETPACK_FUEL_PER_SECOND
  _movement += Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized() * MOVE_SPEED_BASE
  
  oxygen_interval -= delta
  
  if jetpack_fuel >= ESCAPE_JETPACK_FUEL:
    can_escape = true
  
  if can_escape && Input.is_action_just_pressed("activate_jetpack"):
    Store.set_state("game_swap_state", GameConstants.GAME_UPGRADING)
    Store.set_state("game", GameConstants.GAME_ESCAPING)
    _animation_player.play("escape")
  
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

  _camera.set_target_position(global_position)
  _background.region_rect.position = _background.region_rect.position + (_movement * delta)

func _ready() -> void:
  Store.connect("weapon_changed", self, "_on_weapon_changed")

  oxygen = oxygen_capacity
