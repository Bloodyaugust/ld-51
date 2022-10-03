extends Control

const JETPACK_FUEL_UPGRADE_SCALAR: float = 0.5

var data: ItemData
var level: int
var player: Node2D

func set_item_level(new_level: int) -> void:
  var _level_diff: int = new_level - level

  level = new_level

  match data.id:
    "oxygen-tank":
      player.oxygen_capacity += _level_diff
    "jetpack-fuel":
      player.jetpack_fuel_rate += player.JETPACK_FUEL_PER_SECOND * (_level_diff * JETPACK_FUEL_UPGRADE_SCALAR)
