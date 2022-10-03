extends Control

const DIFFICULTY_PER_LEVEL: float = 1.0
const DIFFICULTY_PER_SECOND: float = 0.1
const STARTING_DIFFICULTY: float = 0.0

var difficulty: float = STARTING_DIFFICULTY

var _difficulty_from_levels: float = 0.0

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_STARTING:
          difficulty = STARTING_DIFFICULTY
          _difficulty_from_levels = 0.0
        GameConstants.GAME_UPGRADING:
          _difficulty_from_levels += DIFFICULTY_PER_LEVEL
          difficulty = STARTING_DIFFICULTY + _difficulty_from_levels

func _process(delta: float) -> void:
  if Store.state.game == GameConstants.GAME_IN_PROGRESS:
    difficulty += DIFFICULTY_PER_SECOND * delta

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
