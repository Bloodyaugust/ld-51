extends Control

onready var _animation_player: AnimationPlayer = $"./AnimationPlayer"
onready var _jetpack_progress: Label = $"./JetpackCharge"
onready var _metal: Label = $"./Metal"

var _player: Node2D

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_IN_PROGRESS:
          _animation_player.play("show")
          _player = get_tree().get_nodes_in_group("player")[0]
        GameConstants.GAME_ESCAPING, GameConstants.GAME_ENDING, GameConstants.GAME_TRANSITIONING:
          _animation_player.play("hide")

func _process(delta: float) -> void:
  if Store.state.game == GameConstants.GAME_IN_PROGRESS:
    _jetpack_progress.text = "%d%%" % ((_player.jetpack_fuel / _player.ESCAPE_JETPACK_FUEL) * 100)
    _metal.text = "%s" % Store.state.metal

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
