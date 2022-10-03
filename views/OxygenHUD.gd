extends Control

onready var _animation_player: AnimationPlayer = $"./AnimationPlayer"
onready var _oxygen_bar: ColorRect = $"./OxygenBar"

var _player: Node2D

func _on_oxygen_changed(oxygen: int) -> void:
  _oxygen_bar.rect_scale = Vector2(1, float(oxygen) / float(_player.oxygen_capacity))

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_IN_PROGRESS:
          _animation_player.play("show")

          if !_player:
            _player = get_tree().get_nodes_in_group("player")[0]
            _player.connect("oxygen_changed", self, "_on_oxygen_changed")
            _oxygen_bar.rect_scale = Vector2(1, 1)
        GameConstants.GAME_ESCAPING, GameConstants.GAME_TRANSITIONING:
          _animation_player.play("hide")
        GameConstants.GAME_ENDING:
          _animation_player.play("hide")
          _player = null

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
