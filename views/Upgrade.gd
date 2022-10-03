extends Control

const ITEM_COMPONENT: PackedScene = preload("res://views/components/Item.tscn")

onready var _purchasables: Control = $"%Purchasables"
onready var _return_to_planet: TextureButton = find_node("Return")
onready var _metal: Label = find_node("Metal")

func _on_upgraded() -> void:
  _show()

func _on_return_to_planet_pressed() -> void:
  Store.set_state("game_swap_state", GameConstants.GAME_IN_PROGRESS)
  Store.set_state("game", GameConstants.GAME_TRANSITIONING)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_UPGRADING:
          _show()
        GameConstants.GAME_TRANSITIONING:
          pass
        _:
          visible = false

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
  Store.connect("upgraded", self, "_on_upgraded")
  _return_to_planet.connect("pressed", self, "_on_return_to_planet_pressed")

func _show():
  var _items: Array = UpgradeController.get_all_items()

  GDUtil.queue_free_children(_purchasables)

  for _item in _items:
    var _new_item_component: Control = ITEM_COMPONENT.instance()

    _new_item_component.data = _item
    _purchasables.add_child(_new_item_component)

  _metal.text = "%s" % Store.state.metal

  visible = true
