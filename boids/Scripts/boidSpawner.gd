extends Node

@export
var boidNumber: int = 100

var boid_scene: PackedScene = preload("res://Scenes/boid.tscn")

func _init() -> void:
	for i in range(0, boidNumber):
		var boid = boid_scene.instantiate()
		boid.global_position.x = randf_range(400, 1920)
		boid.global_position.y = randf_range(0, 1080)
		
		self.add_child(boid)
