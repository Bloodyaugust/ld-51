extends Node

const DROP_ACTOR: PackedScene = preload("res://actors/Drop.tscn")
const DROP_DATA: Array = [
  preload("res://data/drops/oxygen_tank.tres"),
  preload("res://data/drops/metal.tres"),
 ]
const WEIGHTED_TABLE = preload("res://lib/chance/WeightedTable.gd")

onready var _drops_container: Node2D = get_tree().get_root().find_node("DropsContainer", true, false)

var _bag

func drop(position: Vector2) -> void:
  var _new_drop: Node2D = DROP_ACTOR.instance()
  var _pick: Dictionary = _bag.pick()
  var _data: DropData
  
  for _drop_data in DROP_DATA:
    if _drop_data.id == _pick.type:
      _data = _drop_data
      break

  _new_drop.data = _data
  _new_drop.global_position = position
  _drops_container.add_child(_new_drop)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_TRANSITIONING:
          GDUtil.queue_free_children(_drops_container)

func _ready() -> void:
  var _drop_objects: Array = []
  _bag = WEIGHTED_TABLE.new()

  for _data in DROP_DATA:
    _drop_objects.append({
      "type": _data.id,
      "weight": _data.pick_weight,
     })

  _bag.initialize_table(_drop_objects)
