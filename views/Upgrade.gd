extends Control

onready var _return_to_planet: Button = find_node("Return")

func _on_return_to_planet_pressed() -> void:
  Store.set_state("game_swap_state", GameConstants.GAME_IN_PROGRESS)
  Store.set_state("game", GameConstants.GAME_TRANSITIONING)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_UPGRADING:
          visible = true
        GameConstants.GAME_TRANSITIONING:
          pass
        _:
          visible = false

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
  _return_to_planet.connect("pressed", self, "_on_return_to_planet_pressed")
