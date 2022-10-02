extends Control

onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")

func swap_game_state() -> void:
  Store.set_state("game", Store.state.game_swap_state)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_TRANSITIONING:
          _animation_player.play("transition")

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
