extends Control

var data: ItemData
var level: int
var player: Node2D

func set_item_level(new_level: int) -> void:
  var _level_diff: int = new_level - level

  level = new_level

  match data.id:
    "oxygen-tank":
      player.oxygen_capacity += _level_diff
