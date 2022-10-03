extends Node

signal item_changed(item_data, level)
signal state_changed(state_key, substate)
signal upgraded

const ray_gun: ItemData = preload("res://data/items/ray-gun.tres")

var persistent_store:PersistentStore
var state: Dictionary = {
  "client_view": "",
  "game": "",
  "metal": 50,
 }

func start_game() -> void:
  set_state("metal", 50)
  set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  state.game_swap_state = GameConstants.GAME_STARTING
  set_state("game", GameConstants.GAME_TRANSITIONING)

func save_persistent_store() -> void:
  if ResourceSaver.save(ClientConstants.CLIENT_PERSISTENT_STORE_PATH, persistent_store) != OK:
    print("Failed to save persistent store")

func set_state(state_key: String, new_state) -> void:
  state[state_key] = new_state
  emit_signal("state_changed", state_key, state[state_key])
  print("State changed: ", state_key, " -> ", state[state_key])

func _initialize():
  set_state("client_view", ClientConstants.CLIENT_VIEW_SPLASH)
  Store.set_state("music_volume", persistent_store.music_volume)

func _on_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_ESCAPING, GameConstants.GAME_UPGRADING:
          get_tree().paused = true
        GameConstants.GAME_OVER:
          set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)
    "music_volume":
      persistent_store.music_volume = substate
      save_persistent_store()

func _ready():
  connect("state_changed", self, "_on_state_changed")
  
  if Directory.new().file_exists(ClientConstants.CLIENT_PERSISTENT_STORE_PATH):
    persistent_store = load(ClientConstants.CLIENT_PERSISTENT_STORE_PATH)

  if !persistent_store:
    persistent_store = PersistentStore.new()
    save_persistent_store()

  call_deferred("_initialize")
