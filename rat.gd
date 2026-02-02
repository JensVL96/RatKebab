extends Path2D

@export var path_curve_array: Array[Curve2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if path_curve_array.is_empty():
		return

	var curve: Curve2D = path_curve_array.pick_random()
	self.curve = curve.duplicate()
	$PathFollow2D.progress = 0.0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
