extends Node2D

const ENEMY_SPAWN: float = 1.0
const ATTACK_WAVE_SPAWN: float = 15.0
const SWARM_SPAWN: float = 30.0
const ENEMY_SCENE: PackedScene = preload("res://actors/Enemy.tscn")
const ENEMY_DATA: UnitData = preload("res://data/enemies/level-0.tres")
const SPAWN_DISTANCE: float = 600.0

var _spawn_timer: Timer
var _attack_timer: Timer
var _swarm_timer: Timer

func _initialize() -> void:
  _spawn_timer = Timer.new()
  _attack_timer = Timer.new()
  _swarm_timer = Timer.new()
  
  _attack_timer.wait_time = ATTACK_WAVE_SPAWN
  _swarm_timer.wait_time = SWARM_SPAWN
  
  _spawn_timer.connect("timeout", self, "_spawn_enemies", [1,ENEMY_DATA])
  get_tree().get_root().add_child(_spawn_timer)
  _spawn_timer.start(ENEMY_SPAWN)
  
func _ready() -> void:
  call_deferred("_initialize")
  
func _spawn_enemies(number: int, unit_data: UnitData) -> void:
  for _i in range(number):
    var _new_enemy: Node2D = ENEMY_SCENE.instance()
    var _player: Node2D = get_tree().get_nodes_in_group("player")[0]
    _new_enemy.data = unit_data
    _new_enemy.global_position = _player.global_position + (Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() * SPAWN_DISTANCE)
    get_tree().get_root().add_child(_new_enemy)
