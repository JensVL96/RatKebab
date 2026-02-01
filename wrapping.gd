extends Node2D

@export var hand: NodePath
@onready var hand_node: Sprite2D = get_node(hand)
signal wrap_folded

@onready var placed := $PlacedIngredients
@onready var templates := $Templates
@onready var StationArea = $StationArea

@onready var first_fold_sprite = preload("res://resources/LeftFold.png")
@onready var second_fold_sprite = preload("res://resources/RightFold.png")
var current_item: Sprite2D = null

@onready var tortilla := $StationArea/Station
@onready var first_fold := $FirstFold/FirstWrap
@onready var second_fold := $SecondFold/SecondWrap

var is_folded := false
var first_fold_side = null  # "left" or "right"
var first_fold_node: Sprite2D = null
var left_pinched := false
var right_pinched := false
var wrap_ready := false
var final_fold_nodes: Array[Sprite2D] = []
var wrap_root: Node2D = null
var just_finished_folding := false

var has_tortilla := false
var hand_type_to_template := {}

func _ready():
	tortilla.visible = false
	first_fold.visible = false
	second_fold.visible = false

	var hand_enum = hand_node.HandType
	hand_type_to_template = {
		hand_enum.TORTILLA: StationArea.get_node("Station"),
		hand_enum.MEAT: templates.get_node("WrapMeat"),
		hand_enum.VEG: templates.get_node("WrapVeg"),
		hand_enum.HERBS: templates.get_node("WrapHerbs"),
		hand_enum.SAUCE: templates.get_node("WrapSauce"),
		hand_enum.CONDIMENT: templates.get_node("WrapCondiments"),
		hand_enum.SPICE: templates.get_node("WrapSalt")
	}

func _fold_wrap():
	var pos = Vector2.ZERO
	if current_item:
		pos = current_item.position
		current_item.queue_free()
		current_item = null
	else:
		print("No tortilla to fold!")
		pos = Vector2.ZERO

	var fold_offset = 16

	var left_fold = Sprite2D.new()
	left_fold.texture = first_fold_sprite
	left_fold.position = pos + Vector2(-fold_offset, 0)
	left_fold.z_index = 1
	$PlacedIngredients.add_child(left_fold)

	var right_fold = Sprite2D.new()
	right_fold.texture = second_fold_sprite
	right_fold.position = pos + Vector2(fold_offset, 0)
	right_fold.z_index = 1
	$PlacedIngredients.add_child(right_fold)
	
	left_fold.scale = Vector2(0.652, 0.412)
	right_fold.scale = Vector2(0.652, 0.412)

func randomize_item(item: Sprite2D):
	# X: left/right, Y: mostly upward
	var x_min := 20
	var x_max := 20
	var y_min := -27.0  # move up
	var y_max := 5      # don’t move down

	item.position += Vector2(
		randf_range(-x_min, x_max),
		randf_range(y_min, y_max)
	)

	# rotation up to ±25°
	item.rotation = deg_to_rad(randf_range(-25, 25))

func place_from_hand():
	var type = hand_node.hand_type
	var hand_enum = hand_node.HandType

	if type == hand_enum.NONE:
		return
	if type == hand_enum.WRAP:
		return

	# --- TORTILLA ---
	if type == hand_enum.TORTILLA:
		if has_tortilla:
			return

		has_tortilla = true
		tortilla.visible = true
		current_item = tortilla

		hand_node.hand_type = hand_enum.NONE
		hand_node.texture = hand_node.hand_default
		return   # ⬅️ IMPORTANT

	# --- TOPPINGS ---
	if not has_tortilla:
		print("Cannot place topping before tortilla")
		return

	if not hand_type_to_template.has(type):
		return

	var template = hand_type_to_template[type]
	current_item = template.duplicate()
	placed.add_child(current_item)
	current_item.visible = true
	current_item.z_index = 1
	randomize_item(current_item)

	hand_node.hand_type = hand_enum.NONE
	hand_node.texture = hand_node.hand_default

func _clear_placed_ingredients():
	for child in placed.get_children():
		child.queue_free()

func pickup_wrap() -> bool:
	if not wrap_ready:
		return false

	tortilla.visible = false
	first_fold.visible = false
	second_fold.visible = false

	# clean ingredients for next wrap
	for child in placed.get_children():
		child.queue_free()

	has_tortilla = false
	wrap_ready = false
	first_fold_side = null
	left_pinched = false
	right_pinched = false
	just_finished_folding = false

	hand_node.hand_type = hand_node.HandType.WRAP
	hand_node.texture = hand_node.hand_wrap

	return true


func _on_station_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			# block placing while a finished wrap exists
			if wrap_ready:
				return

			place_from_hand()

		else:
			# mouse released → pickup
			if just_finished_folding:
				just_finished_folding = false
				return

			if wrap_ready:
				if pickup_wrap():
					emit_signal("wrap_folded")

func _on_left_fold_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not left_pinched:
		get_viewport().set_input_as_handled()
		left_pinched = true
		_create_fold("left")


func _on_right_fold_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not right_pinched:
		get_viewport().set_input_as_handled()
		right_pinched = true
		_create_fold("right")
		
func _create_fold(side: String):
	if not has_tortilla:
		return

	# First fold
	if first_fold_side == null:
		first_fold_side = side

		# hide tortilla
		tortilla.visible = false

		# hide all toppings
		_clear_placed_ingredients()

		first_fold.visible = true
		first_fold.position = tortilla.position
		return

	# Second fold
	if side == first_fold_side:
		return

	first_fold.visible = false
	second_fold.visible = true
	second_fold.position = first_fold.position

	wrap_ready = true
	just_finished_folding = true
	emit_signal("wrap_folded")
