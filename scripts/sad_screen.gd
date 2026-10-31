extends Control

@onready var background = $Background
@onready var music: AudioStreamPlayer = $Music
@onready var rain_sound: AudioStreamPlayer = $RainSound
@onready var thunder_sound: AudioStreamPlayer = $ThunderSound
var flash_duration: float = 0.08
var max_alpha: float = 1.0
var original_alpha: float
var lighting_timer: float = 4
var can_lighting: bool = true

var tween: Tween

func _ready() -> void:
	original_alpha = background.modulate.a

func selected(is_selected: bool):
	if is_selected:
		music.play()
		rain_sound.play()
	else:
		music.stop()
		rain_sound.stop()
		thunder_sound.stop()
		

func on_tap(_pos: Vector2) -> void:
	if can_lighting:
		flash_lighting()

func flash_lighting():
	if tween and tween.is_running():
		tween.kill()

	can_lighting = false

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

	var delay = randf_range(1, 2.5)
	await get_tree().create_timer(delay).timeout

	thunder_sound.pitch_scale = randf_range(0.8, 1.2)
	thunder_sound.play()

	await get_tree().create_timer(lighting_timer).timeout

	can_lighting = true
