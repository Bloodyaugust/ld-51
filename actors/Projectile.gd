extends Node2D

var data: WeaponData
var direction: Vector2

onready var _area2d: Area2D = $"%Area2D"
onready var _visibility_notifier: VisibilityNotifier2D = $"%VisibilityNotifier2D"

func _on_body_entered(body: Node) -> void:
  if body.has_method("hit"):
    body.hit()
  queue_free()

func _on_screen_exited() -> void:
  queue_free()

func _process(delta: float) -> void:
  global_position += direction * delta * data.speed

func _ready() -> void:
  _area2d.connect("body_entered", self, "_on_body_entered")
  _visibility_notifier.connect("screen_exited", self, "_on_screen_exited")
