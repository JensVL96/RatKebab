extends Node2D

@export var customer_scene: PackedScene

@onready var bubble := $Bubble
@onready var bubble_label := $Bubble/Label
@onready var hand := get_node("/root/Workstation/Hand/HandDefault")

var current_customer: Control = null

var is_closing := false
@export var shutter_speed := 500.0  # pixels per second
@onready var shutter := $Shutter

func _ready():
	bubble.visible = false
	spawn_customer()

func _process(delta):
	# move shutter down if restaurant is closing
	shutter.position.y += shutter_speed * delta/10
	if shutter.position.y >= 0:
		shutter.position.y = 0
		set_process(false)
		print("Restaurant fully closed.")

func show_bubble(text: String):
	bubble.visible = true
	bubble_label.text = text

func hide_bubble():
	bubble.visible = false

@export var perfect_count := 0
@export var terrible_count := 0
const PERFECT_LIMIT := 3
const TERRIBLE_LIMIT := 3

func shutdown_restaurant():
	if is_closing:
		return
	is_closing = true
	print("Restaurant shut down!")

	# show shutter parts
	shutter.get_node("ShutterBlinds").visible = true
	shutter.get_node("ShutterPoster").visible = true
	shutter.get_node("ShutterPoster/ShutterText").visible = true

	# start above viewport
	shutter.position.y = -shutter.size.y*2

	set_process(true)  # animate in _process

func celebrate_success():
	if is_closing:
		return
	is_closing = true
	print("Restaurant success!")

	# show shutter parts
	$Newspaper.visible = true

func _on_customer_finished(reaction: String):
	match reaction:
		"Perfect!":
			perfect_count += 1
			if perfect_count >= PERFECT_LIMIT:
				celebrate_success()
		"Terrible!":
			terrible_count += 1
			if terrible_count >= TERRIBLE_LIMIT:
				await get_tree().create_timer(2.0).timeout
				shutdown_restaurant()

func spawn_customer():
	if is_closing:
		return
	if customer_scene == null:
		push_error("Customer scene not assigned!")
		return

	# safety: only one customer at a time
	if current_customer:
		current_customer.queue_free()

	var c := customer_scene.instantiate() as Control
	$WindowContainer/CustomerSpawner.add_child(c)
	#add_child(c)                 # <-- directly under Window
	current_customer = c
	hand.current_customer = c    # hand knows who it's serving
	c.window = self
	c.connect("finished_wrap", Callable(self, "_on_customer_finished"))

func _on_interact_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("interacting with customer")
		if current_customer:
			print("giving him food")
			current_customer.give_wrap(hand)
