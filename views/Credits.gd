extends Control

onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _main_menu_button: Button = find_node("MainMenu")

func _on_main_menu_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_CREDITS:
          visible = true
          _animation_player.play("show")
        ClientConstants.CLIENT_VIEW_SPLASH:
          pass
        _:
          _animation_player.play("hide")

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
  _main_menu_button.connect("pressed", self, "_on_main_menu_pressed")
