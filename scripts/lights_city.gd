extends Sprite2D

@export var min_energy: float = 0.3
@export var max_energy: float = 1.0
@export var speed: float

var time: float = 0.0

func _ready() -> void:
	speed = randfn(0.6, 1.0)

func _process(delta: float) -> void:
	time += delta * speed

	var energy := lerpf(
		min_energy,
		max_energy,
		(sin(time) + 1.0) / 2.0
	)

	modulate.a = energy