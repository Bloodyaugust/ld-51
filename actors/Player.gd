extends KinematicBody2D

const MOVE_SPEED_BASE: float = 25.0

func _process(_delta):
  var _movement: Vector2 = Vector2.ZERO
  
  _movement += Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized() * MOVE_SPEED_BASE
  
  move_and_slide(_movement)
