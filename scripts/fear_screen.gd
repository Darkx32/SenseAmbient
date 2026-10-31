extends Control

const SPRITE = preload("res://prefabs/jumpscare.tscn")

@onready var music: AudioStreamPlayer = $Music
@onready var jumpscare: AudioStreamPlayer = $JumpscareSound
var min_scale: float = 0.8
var max_scale: float = 1.3
var lifetime: float = 1.2
var fade_duration: float = 0.7
var can_jumpscare: bool = true

func _ready() -> void:
	randomize()

func selected(is_selected: bool):
	if is_selected:
		music.play()
	else:
		music.stop()
		jumpscare.stop()

func on_tap(local_position: Vector2) -> void:
	spawn_sprite(local_position)

func spawn_sprite(mouse_pos: Vector2) -> void:
	can_jumpscare = false
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

	tween.tween_callback(func(): 
		sprite.queue_free()
		can_jumpscare = true
	)

	jumpscare.play()
