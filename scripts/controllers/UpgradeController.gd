extends Node

const ITEMS: Array = [
  preload("res://data/items/ray-gun.tres"),
  preload("res://data/items/oxygen-tank.tres"),
 ]

var _player: Node2D

func get_all_items() -> Array:
  var _items: Array = []

  for _item in ITEMS:
    _items.append({
      "data": _item,
      "level": 0,
      "cost": _item.cost_per_level,
      "purchasable": Store.state.metal >= _item.cost_per_level,
    })

  for _owned_item in _player.items.get_children():
    for _item in _items:
      if _owned_item.data.id == _item.data.id:
        _item.level = _owned_item.level
        _item.cost = _item.data.cost_per_level + (_owned_item.level * _item.data.cost_per_level)
        _item.purchasable = Store.state.metal >= _item.cost && _item.level < 5

  return _items

func _ready() -> void:
  Store.connect("state_changed", self, "_on_state_changed")
  
func _on_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_ESCAPING:
          get_tree().paused = true
        GameConstants.GAME_UPGRADING:
          _player = get_tree().get_nodes_in_group("player")[0]
