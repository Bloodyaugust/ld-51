extends KinematicBody2D

signal died
signal oxygen_changed(oxygen)

const MOVE_SPEED_BASE: float = 50.0
const OXYGEN_CAPACITY_BASE: int = 6
const UPGRADE_SCRIPT := preload("res://scripts/upgrade.gd")
const WEAPON_SCRIPT := preload("res://scripts/weapon.gd")
const OXYGEN_USE_INTERVAL: float = 10.0
const JETPACK_FUEL_PER_SECOND: float = 1.0
const ESCAPE_JETPACK_FUEL: float = 60.0

onready var items: Node2D = $"%Items"

var last_move_direction: Vector2 = Vector2.RIGHT
var oxygen: int
var oxygen_capacity: int = OXYGEN_CAPACITY_BASE
var oxygen_interval: float = OXYGEN_USE_INTERVAL
var jetpack_fuel: float = 0.0
var jetpack_fuel_rate: float = JETPACK_FUEL_PER_SECOND
var can_escape: bool = false

onready var _animated_sprite: AnimatedSprite = $"%AnimatedSprite"
onready var _animation_player: AnimationPlayer = $"%AnimationPlayer"
onready var _background: Sprite = get_tree().get_nodes_in_group("background")[0]
onready var _camera: Camera2D = get_tree().get_nodes_in_group("camera")[0]

var _died: bool = false

func hit(damage: int) -> void:
  if !_died:
    oxygen -= damage
    emit_signal("oxygen_changed", oxygen)
    if oxygen <= 0:
      _die()

func refill_oxygen(amount: int) -> void:
  if !_died:
    oxygen = int(clamp(oxygen + amount, 1, oxygen_capacity))
    emit_signal("oxygen_changed", oxygen)

func start_upgrade() -> void:
  Store.set_state("game", GameConstants.GAME_TRANSITIONING)

func _die() -> void:
  _died = true
  emit_signal("died")
  Store.set_state("game_swap_state", GameConstants.GAME_ENDING)
  Store.set_state("game", GameConstants.GAME_TRANSITIONING)
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  queue_free()

func _on_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_IN_PROGRESS:
          global_position = Vector2.ZERO
          _animated_sprite.global_position = Vector2.ZERO
          _animated_sprite.animation = "default"
          jetpack_fuel = 0
          oxygen = oxygen_capacity
          get_tree().paused = false

func _on_item_changed(item_data: ItemData, item_level: int) -> void:
  if item_level == 1:
    var new_item

    match item_data.type:
      "weapon":
        new_item = WEAPON_SCRIPT.new()
      "upgrade":
        new_item = UPGRADE_SCRIPT.new()

    new_item.data = item_data
    new_item.player = self
    new_item.pause_mode = Node.PAUSE_MODE_STOP
    new_item.set_item_level(1)
    items.add_child(new_item)
  else:
    for _item in items.get_children():
      if _item.data.id == item_data.id:
        _item.set_item_level(item_level)

  Store.emit_signal("upgraded")
  
func _process(delta):
  match Store.state.game:
    GameConstants.GAME_ESCAPING, GameConstants.GAME_UPGRADING, GameConstants.GAME_TRANSITIONING:
      return
    _:
      pass

  var _movement: Vector2 = Vector2.ZERO
  var _starting_position: Vector2 = global_position
  
  jetpack_fuel = clamp(jetpack_fuel + delta * jetpack_fuel_rate, 0.0, ESCAPE_JETPACK_FUEL)
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
  _background.region_rect.position = _background.region_rect.position + (global_position - _starting_position)

func _ready() -> void:
  Store.connect("state_changed", self, "_on_state_changed")
  Store.connect("item_changed", self, "_on_item_changed")

  oxygen = oxygen_capacity
