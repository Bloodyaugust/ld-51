extends Control

onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _main_menu_button: Button = find_node("MainMenu")
onready var _time_survived: Label = find_node("TimeSurvived")
onready var _metal_collected: Label = find_node("MetalCollected")
onready var _enemies_killed: Label = find_node("EnemiesKilled")

func _on_main_menu_pressed() -> void:
  Store.set_state("game", GameConstants.GAME_OVER)
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_ENDING:
          print("game ending, showing postgame")
          _time_survived.text = "%ds" % Store.state.round_length
          _metal_collected.text = "%s" % Store.state.metal_collected
          _enemies_killed.text = "%s" % Store.state.enemies_killed
          visible = true
          _animation_player.play("show")
        GameConstants.GAME_OVER:
          print("game over, hiding postgame")
          _animation_player.play("hide")

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
  _main_menu_button.connect("pressed", self, "_on_main_menu_pressed")
