extends Control

onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _music_volume_slider: HSlider = $"%MusicVolume"
onready var _main_menu_button: Button = find_node("MainMenu")

func _on_main_menu_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

func _on_music_volume_slider_changed(value: float) -> void:
  Store.set_state("music_volume", value)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_OPTIONS:
          visible = true
          _animation_player.play("show")
        _:
          _animation_player.play("hide")
    "music_volume":
      _music_volume_slider.value = substate

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
  _main_menu_button.connect("pressed", self, "_on_main_menu_pressed")
  _music_volume_slider.connect("value_changed", self, "_on_music_volume_slider_changed")
