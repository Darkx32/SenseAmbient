extends Control

@onready var background = $Background
var flash_duration: float = 0.08
var max_alpha: float = 1.0
var original_alpha: float

var tween: Tween

func _ready() -> void:
	original_alpha = background.modulate.a

func on_tap(_pos: Vector2) -> void:
	flash_lighting()

func flash_lighting():
	if tween and tween.is_running():
		tween.kill()

	background.modulate.a = 0.0

	tween = create_tween()

	tween.tween_property(background, "modulate:a", max_alpha, 0.5)
	tween.tween_property(background, "modulate:a", 0.0, flash_duration)

	tween.tween_interval(0.04)
	tween.tween_property(background, "modulate:a", max_alpha, 0.05)
	tween.tween_property(background, "modulate:a", 0.0, flash_duration * 1.2)

	tween.tween_callback(func(): 
		background.modulate.a = original_alpha
	)
