extends Control

@onready var background: ColorRect = $Background

var radius: float = 20.0
var color: Color = Color.ALICE_BLUE
var circles: Array[Vector2] = []

var max_circles: int = 3
var respawn_delay: float = 1.0

var width: float
var height: float
var half_radius: float

const BUBBLE_PARTICLE = preload("res://prefabs/bubble_particle.tscn")
const BUBBLE_SOUND = preload("res://prefabs/bubble_sound.tscn")

func _ready() -> void:
	color.a = 0.5
	var screen_size = get_viewport_rect().size

	half_radius = radius / 2.0
	width = screen_size.x - half_radius
	height = screen_size.y - half_radius

	background.draw.connect(_on_background_draw)

	for i in max_circles:
		spawn_circle()

func _on_background_draw() -> void:
	for pos in circles:
		background.draw_circle(pos, radius, color)

func spawn_circle() -> void:
	var new_pos = Vector2(randf_range(half_radius, width), randf_range(half_radius, height))
	circles.append(new_pos)
	background.queue_redraw()

func on_tap(local_position: Vector2) -> void:
	for i in range(circles.size() - 1, -1, -1):
		var c_pos = circles[i]
		if local_position.distance_to(c_pos) <= radius:
			spawn_particles(c_pos)
			circles.remove_at(i)
			background.queue_redraw()
			
			get_tree().create_timer(respawn_delay).timeout.connect(spawn_circle)
			break

func spawn_particles(local_position: Vector2) -> void:
	var particles = BUBBLE_PARTICLE.instantiate() as GPUParticles2D
	particles.emitting = true
	particles.position = local_position
	particles.finished.connect(particles.queue_free)

	var sound = BUBBLE_SOUND.instantiate() as AudioStreamPlayer
	sound.finished.connect(sound.queue_free)

	add_child(particles)
	add_child(sound)

func clear() -> void:
	for child in get_children():
		if child is GPUParticles2D or child is AudioStreamPlayer:
			child.queue_free()