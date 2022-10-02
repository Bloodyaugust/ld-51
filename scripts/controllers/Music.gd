extends Node

onready var _music_bus_index: int = AudioServer.get_bus_index("Music")
onready var _game_music_1: AudioStreamPlayer = $"%game-1"
onready var _title_music: AudioStreamPlayer = $"%title"

func _on_state_changed(state_key: String, substate) -> void:
  match state_key:
    "music_volume":
      AudioServer.set_bus_volume_db(_music_bus_index, substate)
    "game":
      match substate:
        GameConstants.GAME_OVER:
          _title_music.play()
          _game_music_1.stop()
        GameConstants.GAME_STARTING:
          _title_music.stop()
          _game_music_1.play()

func _ready() -> void:
  Store.connect("state_changed", self, "_on_state_changed")
