extends Node2D

# Preload your sprite scene
@export var SpriteScene: PackedScene = preload("res://Rat.tscn")
@export var speed: float = 100.0  # Optional default speed for the sprite

@export var workstation_scene: PackedScene = preload("res://Workstation.tscn")
@onready var panel = $CanvasLayer/Panel

signal update_text

func _ready():
	# Connect the panel's "done" signal to this scene
	if not panel.is_connected("done", Callable(self, "_on_panel_done")):
		panel.connect("done", Callable(self, "_on_panel_done"))
	
	# Optionally connect "update_text" if you want the panel label updated
	self.connect("update_text", Callable(panel, "_update_text"))



func spawn_rat():
	var instance = SpriteScene.instantiate()
	add_child(instance)
	var signal_node = instance.get_node("PathFollow2D/Rat")

	signal_node.rat_shot.connect(self._rat_killed)

func _rat_killed():
	panel.remaining -= 1
	panel._update_text()

	if panel.remaining <= 0:
		panel.emit_signal("done")


func _on_panel_done() -> void:
	#queue_free()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(workstation_scene)
