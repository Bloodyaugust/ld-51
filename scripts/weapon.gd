extends Node

const PROJECTILE_SCENE: PackedScene = preload("res://actors/Projectile.tscn")
const FIRE_INTERVAL_UPGRADE_SCALAR: float = 0.5

var data: ItemData
var level: int = 0
var player: Node2D
var fire_interval: float

var _time_to_fire: float

func set_item_level(new_level: int) -> void:
  var _level_diff: int = new_level - level

  level = new_level

  fire_interval -= fire_interval * (_level_diff * FIRE_INTERVAL_UPGRADE_SCALAR)

func _fire() -> void:
  var _new_projectile: Node2D = PROJECTILE_SCENE.instance()

  _new_projectile.data = data
  _new_projectile.global_position = player.global_position
  _new_projectile.direction = Vector2.RIGHT
  _new_projectile.weapon = self

  # TODO: handle direction of projectile for other weapon types
  if "facing" in data.flags: 
    _new_projectile.direction = player.last_move_direction

  if "targeting" in data.flags:
    var _enemies = get_tree().get_nodes_in_group("enemies")

    _enemies.sort_custom(self, "_sort_distance_to_player")

    if _enemies.size() > 0:
      _new_projectile.direction = player.global_position.direction_to(_enemies[0].global_position)

  get_tree().get_root().add_child(_new_projectile)

func _process(delta: float) -> void:
  _time_to_fire -= delta
  
  if _time_to_fire <= 0:
    _time_to_fire = fire_interval
    _fire()
      
func _ready() -> void:
  fire_interval = data.fire_interval
  _time_to_fire = fire_interval

func _sort_distance_to_player(a: Node2D, b: Node2D) -> bool:
  return (a.global_position.distance_squared_to(player.global_position)) < (b.global_position.distance_squared_to(player.global_position))
