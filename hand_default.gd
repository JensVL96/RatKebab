extends Sprite2D

@onready var hand_default = preload("res://Hand/HandDefault.png")
@onready var hand_grab = preload("res://Hand/HandGrab.png")
@onready var hand_pinch = preload("res://Hand/HandPinch.png")

@onready var hand_condiment = preload("res://Hand/HandCondiment.png")
@onready var hand_spice = preload("res://Hand/HandSalt.png")
@onready var hand_herbs = preload("res://Hand/HandHerbs.png")
@onready var hand_vegetables = preload("res://Hand/HandVegetables.png")
@onready var hand_wrap = preload("res://Hand/HandWrap.png")
@onready var hand_meat = preload("res://Hand/HandMeat.png")
@onready var hand_tortilla = preload("res://Hand/HandTortilla.png")
@onready var hand_sauce = preload("res://Hand/HandSauce.png")

@onready var wrapping_station := get_node("/root/Workstation/Wrapping")

enum HandType { NONE, TORTILLA, MEAT, VEG, HERBS, SAUCE, CONDIMENT, SPICE, WRAP }
var hand_type: HandType = HandType.NONE

func _ready():
	texture = hand_default
	if wrapping_station:
		wrapping_station.wrap_folded.connect(_on_wrap_folded)
		print("Signal connected")
	else:
		print("wrapping_station is null")

func _process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		texture = hand_grab

func _on_wrap_folded():
	# Replace hand sprite with wrap-holding sprite
	texture = hand_wrap  # or whatever sprite indicates holding the folded wrap
	# Optionally, you could parent the folded wrap to the hand here
	print("Wrap folded! Hand can now pick it up.")

#func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == MOUSE_BUTTON_LEFT:
#			if event.pressed:
#				texture = hand_grab
#			else:
#				texture = hand_default

#func _unhandled_input(event):
#	if event is InputEventMouseButton and !event.pressed:
#		texture = hand_default


func _on_wrap_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_tortilla
		hand_type = HandType.TORTILLA


func _on_meat_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_meat
		hand_type = HandType.MEAT
		


func _on_l_rack_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_spice
		hand_type = HandType.SPICE


func _on_r_rack_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_condiment
		hand_type = HandType.CONDIMENT


func _on_veg_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_vegetables
		hand_type = HandType.VEG


func _on_herb_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_herbs
		hand_type = HandType.HERBS


func _on_sauce_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and !event.pressed:
		texture = hand_sauce
		hand_type = HandType.SAUCE


func _on_station_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if event is InputEventMouseButton and not event.pressed:
	#	if wrapping_station.pickup_wrap():
	#		texture = hand_wrap
	#		hand_type = HandType.TORTILLA
	pass
