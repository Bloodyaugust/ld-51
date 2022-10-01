extends KinematicBody2D

const MOVE_SPEED_BASE: float = 25.0
const WEAPON_SCRIPT := preload("res://scripts/weapon.gd")

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "weapons":
      var new_weapon := WEAPON_SCRIPT.new()
      new_weapon.data = substate[0]
      add_child(new_weapon)
  
func _process(_delta):
  var _movement: Vector2 = Vector2.ZERO
  
  _movement += Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized() * MOVE_SPEED_BASE
  
  move_and_slide(_movement)

func _ready() -> void:
  Store.connect("state_changed", self, "_on_store_state_changed")
