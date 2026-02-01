extends Node2D

@export var customer_scene: PackedScene
@onready var people_layer := $PeopleLayer   # Node2D in your scene to hold customers

func spawn_customer():
	var c = customer_scene.instantiate()
	people_layer.add_child(c)
	c.position = Vector2(c.enter_x, 0)  # start at y = 0
