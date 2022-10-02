extends Node

signal state_changed(state_key, substate)
signal weapon_changed(weapon_data, level)

const ray_gun: WeaponData = preload("res://data/weapons/ray-gun.tres")

var persistent_store:PersistentStore
var state: Dictionary = {
  "client_view": "",
  "game": "",
  "weapons": []
 }

func start_game() -> void:
  set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  set_state("game", GameConstants.GAME_STARTING)

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
