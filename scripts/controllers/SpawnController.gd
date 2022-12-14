extends Node2D

const ENEMY_SPAWN: float = 0.75
const ATTACK_WAVE_SPAWN: float = 15.0
const SWARM_SPAWN: float = 60.0
const ENEMY_SCENE: PackedScene = preload("res://actors/Enemy.tscn")
const PLAYER_SCENE: PackedScene = preload("res://actors/Player.tscn")
const ENEMY_DATA: UnitData = preload("res://data/enemies/level-0.tres")
const ATTACK_ENEMY_DATA: UnitData = preload("res://data/enemies/fast-attack.tres")
const SPAWN_DISTANCE: float = 600.0

onready var _enemies_container: Node2D = get_tree().get_root().find_node("Enemies", true, false)

var _spawn_timer: Timer
var _attack_timer: Timer
var _swarm_timer: Timer
var _player: Node2D

func _initialize() -> void:
  _spawn_timer = Timer.new()
  _attack_timer = Timer.new()
  _swarm_timer = Timer.new()

  _spawn_timer.connect("timeout", self, "_spawn_enemies", [1, ENEMY_DATA])
  _attack_timer.connect("timeout", self, "_spawn_enemies", [10, ATTACK_ENEMY_DATA])
  _swarm_timer.connect("timeout", self, "_spawn_enemies", [50, ENEMY_DATA])
  get_tree().get_root().add_child(_spawn_timer)
  get_tree().get_root().add_child(_attack_timer)
  get_tree().get_root().add_child(_swarm_timer)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_STARTING:
          _player = PLAYER_SCENE.instance()
          get_tree().get_root().add_child(_player)
          Store.call_deferred("set_state", "game", GameConstants.GAME_UPGRADING)
        GameConstants.GAME_ESCAPING, GameConstants.GAME_OVER, GameConstants.GAME_ENDING, GameConstants.GAME_TRANSITIONING:
          _spawn_timer.stop()
          _attack_timer.stop()
          _swarm_timer.stop()
        GameConstants.GAME_IN_PROGRESS:
          GDUtil.queue_free_children(_enemies_container)
          _spawn_timer.start(ENEMY_SPAWN)
          _attack_timer.start(ATTACK_WAVE_SPAWN)
          _swarm_timer.start(SWARM_SPAWN)
  
func _ready() -> void:
  Store.connect("state_changed", self, "_on_state_changed")
  call_deferred("_initialize")
  
func _spawn_enemies(number: int, unit_data: UnitData) -> void:
  var _clump_point: Vector2 = _player.global_position + (Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() * SPAWN_DISTANCE)

  for _i in range(number):
    var _new_enemy: Node2D = ENEMY_SCENE.instance()
    var _player: Node2D = get_tree().get_nodes_in_group("player")[0]
    _new_enemy.data = unit_data

    if "clump" in unit_data.flags:
      _new_enemy.global_position = _clump_point + Vector2(randf(), randf())
    else:
      _new_enemy.global_position = _player.global_position + (Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() * SPAWN_DISTANCE)

    _enemies_container.add_child(_new_enemy)
