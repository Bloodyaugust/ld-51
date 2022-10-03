extends Sprite

const DROP_ATTRACT_DISTANCE: float = 250.0
const DROP_ATTRACT_SPEED: float = 300.0
const DROP_COLLECT_DISTANCE: float = 5.0

var data: DropData

var _player: Node2D

func _pickup() -> void:
  match data.id:
    "metal":
      Store.set_state("metal", Store.state.metal + 1)
      Store.set_state("metal_collected", Store.state.metal_collected + 1)
    "oxygen-tank":
      _player.refill_oxygen(1)

  queue_free()

func _process(delta: float) -> void:
  if !GDUtil.reference_safe(_player):
    queue_free()
    return

  if _player.global_position.distance_to(global_position) <= DROP_ATTRACT_DISTANCE:
    global_position += global_position.direction_to(_player.global_position) * DROP_ATTRACT_SPEED * delta

  if _player.global_position.distance_to(global_position) <= DROP_COLLECT_DISTANCE:
    _pickup()

func _ready() -> void:
  var _players = get_tree().get_nodes_in_group("player")

  if _players.size() == 0:
    queue_free()
    return

  _player = _players[0]

  texture = data.sprite
