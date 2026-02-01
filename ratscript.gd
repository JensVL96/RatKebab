extends StaticBody2D

signal rat_shot


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_event.connect(_on_Area2D_input_event)
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.get_class() == "InputEventMouseButton" and event.pressed == true:
		emit_signal("rat_shot")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
