extends Node2D

@export var sprite_sheet: Texture2D
@export var columns: int = 4
@export var rows: int = 5

@export var enter_x := 1000    # offscreen right
@export var stop_x := 500      # middle of window
@export var exit_x := -200     # offscreen left
@export var move_speed := 300
@export var wait_time := 1.0   # pause in middle

enum State { ENTERING, WAITING, LEAVING }
var state := State.ENTERING
var timer := 0.0

@onready var person_sprite: Sprite2D = $Person

func _ready():
	# Assign sprite texture and random frame
	person_sprite.texture = sprite_sheet
	person_sprite.hframes = columns
	person_sprite.vframes = rows
	person_sprite.frame = randi() % (columns * rows)
	
	# Start offscreen right
	position = Vector2(enter_x, 150)

func _process(delta):
	match state:
		State.ENTERING:
			position = position.move_toward(Vector2(stop_x, position.y), move_speed * delta)
			if abs(position.x - stop_x) < 1:
				position.x = stop_x
				state = State.WAITING
				timer = wait_time

		State.WAITING:
			timer -= delta
			if timer <= 0:
				state = State.LEAVING
		
		State.LEAVING:
			position = position.move_toward(Vector2(exit_x, position.y), move_speed * delta)
			if abs(position.x - exit_x) < 1:
				# Loop back to start
				position.x = enter_x
				state = State.ENTERING
				
				# Swap person frame for next loop
				person_sprite.frame = randi() % (columns * rows)
