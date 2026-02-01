extends Panel

@export var total_required := 8
@onready var label = $Label
var remaining: int

signal done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remaining  = total_required
	_update_text()

func _rat_killed():
	remaining -= 1
	remaining = max(remaining, 0)
	_update_text()
	
	if remaining == 0:
		emit_signal("done")

func _update_text():
	label.text = "Kill %d more rats!" % [remaining]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
