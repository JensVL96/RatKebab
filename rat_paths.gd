extends Node2D

# Preload your sprite scene
@export var SpriteScene: PackedScene = preload("res://Rat.tscn")
@export var speed: float = 100.0  # Optional default speed for the sprite

signal update_text

func _ready():
	pass



func spawn_rat():
	var instance = SpriteScene.instantiate()
	add_child(instance)
	var signal_node = instance.get_node("PathFollow2D/Rat")

	signal_node.rat_shot.connect(self._rat_killed)

func _rat_killed():
	emit_signal("update_text")


func _on_panel_done() -> void:
	queue_free()
