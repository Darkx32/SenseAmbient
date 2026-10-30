extends Control

const SPRITE = preload("res://prefabs/jumpscare.tscn")

var min_scale: float = 0.8
var max_scale: float = 1.3
var lifetime: float = 1.2
var fade_duration: float = 0.7

func _ready() -> void:
	randomize()

func on_tap(local_position: Vector2) -> void:
	spawn_sprite(local_position)

func spawn_sprite(mouse_pos: Vector2) -> void:
	var sprite: Sprite2D = SPRITE.instantiate()

	sprite.scale *= randf_range(min_scale, max_scale)
	sprite.rotation_degrees = randf_range(-45.0, 45.0)

	sprite.centered = true
	sprite.position = mouse_pos

	add_child(sprite)

	var tween := create_tween()
	tween.tween_interval(lifetime)

	tween.tween_property(
		sprite,
		"modulate:a",
		0.0,
		fade_duration
	)

	tween.tween_callback(sprite.queue_free)
