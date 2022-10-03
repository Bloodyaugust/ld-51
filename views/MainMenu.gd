extends Control

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var _play_button: Button = find_node("Play")
onready var _options_button: Button = find_node("Options")
onready var _howtoplay_button: Button = find_node("HowToPlay")

func _on_howtoplay_button_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_HOWTOPLAY)

func _on_play_button_pressed() -> void:
  Store.start_game()

func _on_options_button_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_OPTIONS)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_MAIN_MENU:
          visible = true
          _animation_player.play("ui_show")
        _:
          _animation_player.play_backwards("ui_show")
          yield(_animation_player, "animation_finished")
          visible = false

func _ready():
  _play_button.connect("pressed", self, "_on_play_button_pressed")
  _options_button.connect("pressed", self, "_on_options_button_pressed")
  _howtoplay_button.connect("pressed", self, "_on_howtoplay_button_pressed")

  Store.connect("state_changed", self, "_on_state_changed")
