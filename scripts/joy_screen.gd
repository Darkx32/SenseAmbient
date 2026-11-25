extends Control

@export var tile_size: int = 16
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var music: AudioStreamPlayer = $Music
@onready var leaves_sound: AudioStreamPlayer = $LeavesSound
var tiles = [
	Vector2i(0, 0), # Grass
	Vector2i(1, 0), # Grass with defails
	Vector2i(2, 0), # Grass with flowers
	Vector2i(7, 3), # Grass with rocks
]

var width: int
var height: int
var particles_list: Array[GPUParticles2D]
var max_size_of_list: int = 50

const FLOWER_PARTICLE = preload("res://prefabs/flower_particle.tscn")

func _ready() -> void:
	randomize()

	var screen_size = get_viewport_rect().size

	width = ceili(screen_size.x / tile_size)
	height = ceili(screen_size.y / tile_size)

	generate_scene()

func on_tap(local_position: Vector2) -> void:
	create_flowers(local_position)

func create_flowers(local_position: Vector2):
	var particles = FLOWER_PARTICLE.instantiate() as GPUParticles2D
	particles.emitting = true
	particles.position = local_position
	add_child(particles)
	particles_list.append(particles)
	if particles_list.size() > max_size_of_list:
		var variant = particles_list[0]
		particles_list.erase(variant)
		if is_instance_valid(variant):
			variant.queue_free()

	leaves_sound.play()

	await get_tree().create_timer(1.8).timeout

	if particles:
		particles.speed_scale = 0

func generate_scene():
	tilemap.clear()

	for x in range(width):
		for y in range(height):
			var tile_position = Vector2i(x, y)
			var factor = randf()

			if factor < 0.88:
				tilemap.set_cell(tile_position, 0, tiles[0])
			elif factor < 0.98:
				tilemap.set_cell(tile_position, 0, tiles[1])
			elif factor < 0.99:
				tilemap.set_cell(tile_position, 0, tiles[2])
			else:
				tilemap.set_cell(tile_position, 0, tiles[3])

func selected(is_selected: bool):
	if is_selected:
		music.play()
	else:
		music.stop()
		leaves_sound.stop()

func clear() -> void:
	for child in get_children():
		if child is GPUParticles2D:
			if is_instance_valid(child):
				child.queue_free()
	particles_list.clear()
