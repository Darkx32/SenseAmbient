extends Control

var line_count := 12
var points_per_line: int
var radius: float
@export var line_width := 1.5
@export var elapsed := 0.0
@export var drawing_speed := 180.0
var movement := 3.0

var rng := RandomNumberGenerator.new()

@onready var background: ColorRect = $Background
const PAPER_SOUND = preload("res://prefabs/paper_sound.tscn")

func _ready() -> void:
	rng.randomize()

	background.configure({
		"line_width": line_width,
		"elapsed": elapsed,
		"drawing_speed": drawing_speed,
	})

func on_tap(local_position: Vector2):
	var paper_sound = PAPER_SOUND.instantiate() as AudioStreamPlayer
	add_child(paper_sound)

	var strands: Array[PackedVector2Array] = []
	radius = rng.randf_range(35, 70)

	for s in range(line_count):
		var points := PackedVector2Array()

		var angle := rng.randf_range(0.0, TAU)
		var current := Vector2.ZERO

		points_per_line = rng.randi_range(20, 65)

		for i in range(points_per_line):
			points.append(current)

			angle += rng.randf_range(-1.4, 1.4)

			var next := current + Vector2.from_angle(angle) * rng.randf_range(5.0, 12.0)

			if next.length() > radius:
				angle = (-current).angle() + rng.randf_range(-1.0, 1.0)
				next = current + Vector2.from_angle(angle) * 8.0

			current = next

		strands.append(points)

	if background.has_method("add_effect"):
		background.add_effect({
			"position": local_position,
			"strands": strands,
			"time": 0.0
		})

	paper_sound.play()
	paper_sound.finished.connect(paper_sound.queue_free)

	queue_redraw()

func clear() -> void:
	if background.has_method("clear_effects"):
		background.clear_effects()
