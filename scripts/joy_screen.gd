extends Control

@export var tile_size: int = 16
@onready var tilemap: TileMapLayer = $TileMapLayer
var tiles = [
	Vector2i(0, 0), # Grass
	Vector2i(1, 0), # Grass with defails
	Vector2i(2, 0), # Grass with flowers
	Vector2i(7, 3), # Grass with rocks
]

var width: int
var height: int

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
	particles.finished.connect(particles.queue_free)
	particles.position = local_position
	add_child(particles)

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

func clear() -> void:
	for child in get_children():
		if child is GPUParticles2D:
			child.queue_free()
