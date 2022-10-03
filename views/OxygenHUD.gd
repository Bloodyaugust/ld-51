extends Control

const OXYGEN_EMPTY_COLOR: Color = Color("#C4B28D")
const OXYGEN_FULL_COLOR: Color = Color("#4796B5")
const OXYGEN_TICK_COMPONENT: PackedScene = preload("res://views/components/OxygenTick.tscn")

onready var _animation_player: AnimationPlayer = $"./AnimationPlayer"
onready var _oxygen_ticks_container: HBoxContainer = $"%OxygenTicks"

var _player: Node2D

func _initialize_oxygen_ticks() -> void:
  GDUtil.queue_free_children(_oxygen_ticks_container)

  for _i in range(_player.oxygen_capacity):
    var _new_oxygen_tick: Control = OXYGEN_TICK_COMPONENT.instance()

    _oxygen_ticks_container.add_child(_new_oxygen_tick)

func _on_oxygen_changed(oxygen: int) -> void:
  for _i in range(_oxygen_ticks_container.get_child_count()):
    var _oxygen_tick: Control = _oxygen_ticks_container.get_child(_i)
    
    if _i < oxygen:
      _oxygen_tick.modulate = OXYGEN_FULL_COLOR
    else:
      _oxygen_tick.modulate = OXYGEN_EMPTY_COLOR

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_IN_PROGRESS:
          _animation_player.play("show")

          if !_player:
            _player = get_tree().get_nodes_in_group("player")[0]
            _player.connect("oxygen_changed", self, "_on_oxygen_changed")

          _initialize_oxygen_ticks()
        GameConstants.GAME_ESCAPING:
          _animation_player.play("hide")
        GameConstants.GAME_OVER:
          _animation_player.play("hide")
          _player = null

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
