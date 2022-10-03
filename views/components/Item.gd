extends Control

const OWNED_UPGRADE: PackedScene = preload("res://views/components/Owned.tscn")
const UNOWNED_UPGRADE: PackedScene = preload("res://views/components/Unowned.tscn")

var data: Dictionary

onready var _buy_button: Button = $"%Buy"
onready var _cost: Label = $"%Cost"
onready var _icon: TextureRect = $"%Icon"
onready var _level: HBoxContainer = $"%Level"
onready var _name: Label = $"%Name"

func _on_buy_pressed() -> void:
  Store.set_state("metal", Store.state.metal - data.cost)
  Store.emit_signal("item_changed", data.data, data.level + 1)

func _ready() -> void:
  _buy_button.connect("pressed", self, "_on_buy_pressed")
  
  _buy_button.disabled = !data.purchasable
  _cost.text = "%s" % data.cost
  _icon.texture = load("res://icon.png")
  _name.text = data.data.name

  _update_level()

func _update_level() -> void:
  GDUtil.queue_free_children(_level)
  
  for _i in range(5):
    if _i < data.level:
      _level.add_child(OWNED_UPGRADE.instance())
    else:
      _level.add_child(UNOWNED_UPGRADE.instance())
