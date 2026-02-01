extends Node2D

@export var customer_scene: PackedScene
@onready var people_layer := $CustomerSpawner  # Node2D to hold customers

func _ready():
	# Spawn first customer for testing
	spawn_customer()

func spawn_customer():
	if customer_scene == null:
		push_error("Customer scene not assigned!")
		return
	
	var c = customer_scene.instantiate()
	people_layer.add_child(c)
	c.position = Vector2(c.enter_x, 200)  # start offscreen
