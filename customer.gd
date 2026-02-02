extends Control

signal finished_wrap(reaction: String)  # "Perfect", "Fine", "Had better", "Terrible"

@export var sprite_sheet: Texture2D
@export var columns: int = 4
@export var rows: int = 5

@export var enter_x := 1000
@export var stop_x := 500
@export var exit_x := -200
@export var move_speed := 300.0
@export var wait_time := 1.0

enum State { ENTERING, WAITING, INTERACTING, REACTING, LEAVING }
var state := State.ENTERING
var timer := 0.0
var waiting_entered := false

var request_texts := [
	"I'd like a \nsweet wrap!",
	"One juicy wrap, \nplease.",
	"Can you make \nme a spicy wrap?",
]

const MAX_INGREDIENTS = 8
const FULL_PROFILE_MIN = 5
const MEAT_BASE = 12
const FULL_PROFILE_BONUS = 2
const STACK_MULTIPLIER = 1.2
const PREF_MULTIPLIER = 1.2
enum Flavor { NONE, SWEET, SPICY, JUICY }
var wrap_ingredients: Array = []  # strings: ["salt", "herbs", "rat_meat", ...]
var has_tortilla := false
var has_meat := false

var ingredient_flavors = {
	"herbs": [Flavor.JUICY],
	"vegetables": [Flavor.JUICY],
	"salt": [Flavor.SPICY],
	"red_sauce": [Flavor.SPICY, Flavor.SWEET],
	"yellow_condiment": [Flavor.SWEET],
	"rat_meat": [Flavor.NONE],
	"tortilla": [] # neutral
}

@onready var person_sprite: Sprite2D = $Person
var window: Node = null

func _ready():
	person_sprite.texture = sprite_sheet
	person_sprite.hframes = columns
	person_sprite.vframes = rows
	person_sprite.frame = randi() % (columns * rows)

	# start offscreen
	position = Vector2(enter_x, 160)

func _process(delta):
	match state:

		State.ENTERING:
			position.x = move_toward(position.x, stop_x, move_speed * delta)
			if abs(position.x - stop_x) < 1:
				position.x = stop_x
				state = State.WAITING
				timer = wait_time

		State.WAITING:
			if not waiting_entered:
				waiting_entered = true
				if window:
					window.show_bubble(request_texts.pick_random())

		State.REACTING:
			timer -= delta
			if timer <= 0:
				state = State.LEAVING

		State.LEAVING:
			position.x = move_toward(position.x, exit_x, move_speed * delta)
			if position.x <= exit_x:
				if window:
					window.hide_bubble()
					window.spawn_customer()
				queue_free()

func add_ingredient(ingredient: String):
	if wrap_ingredients.size() >= MAX_INGREDIENTS:
		print("Cannot add more ingredients: ", ingredient)
		return # cannot add more

	wrap_ingredients.append(ingredient)
	if ingredient == "rat_meat":
		has_meat = true
	if ingredient == "tortilla":
		has_tortilla = true

	print("Added ingredient:", ingredient)
	print("Wrap now has:", wrap_ingredients)
	print("Has meat:", has_meat, "Has tortilla:", has_tortilla)

func score_wrap(request_flavor: Flavor) -> float:
	print("Scoring wrap. Ingredients:", wrap_ingredients)
	print("Has tortilla:", has_tortilla, "Has meat:", has_meat)

	if not has_meat or not has_tortilla:
		print("Wrap incomplete during scoring!")
		return -MEAT_BASE  # incomplete wrap

	var total_score = 0.0
	var prev_flavor: Flavor = Flavor.NONE

	for ing in wrap_ingredients:
		if not ingredient_flavors.has(ing):
			continue

		var ing_score = 1.0  # base score per ingredient

		# multiplier for customer preference
		for f in ingredient_flavors[ing]:
			if f == request_flavor:
				ing_score *= PREF_MULTIPLIER

		# stacking bonus if same flavor repeats
		if prev_flavor != Flavor.NONE and prev_flavor not in ingredient_flavors[ing]:
			ing_score *= STACK_MULTIPLIER

		total_score += ing_score

		# remember last flavor for stacking
		if ingredient_flavors[ing].size() > 0:
			prev_flavor = ingredient_flavors[ing][0]
		else:
			prev_flavor = Flavor.NONE

	# full profile bonus
	if wrap_ingredients.size() >= FULL_PROFILE_MIN:
		total_score += FULL_PROFILE_BONUS

	# final score subtract meat dominance
	return total_score - MEAT_BASE


func give_wrap(hand_node: Node):
	if state != State.WAITING:
		return

	if not has_tortilla or not has_meat:
		if window:
			window.show_bubble("Wrap incomplete!")
		return

	if hand_node.hand_type != hand_node.HandType.WRAP:
		if window:
			window.show_bubble("I need a folded wrap!")
		return

	var request_flavor = Flavor.values()[randi() % 3]  # example: randomly pick requested flavor
	var score = score_wrap(request_flavor)
	var reaction = ""
	print("final score: ", score)

	if score >= -1:
		reaction = "Perfect!"
	elif score >= -3:
		reaction = "Fine."
	elif score >= -5:
		reaction = "Had better!"
	else:
		reaction = "Terrible!"

	if window:
		window.show_bubble(reaction)
		emit_signal("finished_wrap", reaction)

	state = State.REACTING
	timer = 1.5

	# reset hand
	hand_node.hand_type = hand_node.HandType.NONE
	hand_node.texture = hand_node.hand_default

	# reset wrap
	wrap_ingredients.clear()
	has_meat = false
	has_tortilla = false
