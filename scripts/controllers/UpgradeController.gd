extends Node

func _ready() -> void:
  Store.connect("state_changed", self, "_on_state_changed")
  
func _on_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_ESCAPING:
          get_tree().paused = true
