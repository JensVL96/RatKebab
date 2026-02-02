extends Area2D


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var customer = get_parent()  # Area2D parent is Customer
		customer.give_wrap()
		print("customer received the wrap")
