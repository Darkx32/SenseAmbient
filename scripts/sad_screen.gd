extends Control

@onready var background = $Background
@onready var music: AudioStreamPlayer = $Music
@onready var rain_sound: AudioStreamPlayer = $RainSound
@onready var thunder_sound: AudioStreamPlayer = $ThunderSound
@onready var lights = $Background/Lights
@onready var lighting_bolt: Line2D = $LightingBolt

var flash_duration: float = 0.08
var max_alpha: float = 1.0
var original_alpha: float
var lighting_timer: float = 4
var can_lighting: bool = true

var tween: Tween
var background_realsize: Vector2 = Vector2(640.0, 360.0)

func _ready() -> void:
	original_alpha = background.modulate.a
	lighting_bolt.visible = false
	background.resized.connect(update_lights)

	update_lights()

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
	strike_bolt()

	tween = create_tween()

	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", max_alpha, 0.05)
	tween.tween_property(lighting_bolt, "modulate:a", 1.0, 0.05)

	tween.chain().set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, flash_duration)
	tween.tween_property(lighting_bolt, "modulate:a", 0.0, flash_duration * 0.8)

	tween.chain().tween_interval(0.04)

	tween.chain().set_parallel(true)
	tween.tween_property(background, "modulate:a", max_alpha, 0.04)
	tween.tween_property(lighting_bolt, "modulate:a", 0.9, 0.04)

	tween.chain().set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, flash_duration * 1.2)
	tween.tween_property(lighting_bolt, "modulate:a", 0.0, flash_duration)

	tween.chain().tween_callback(func(): 
		background.modulate.a = original_alpha
		lighting_bolt.visible = false
	)

	lights.modulate.a = 0.01
	var delay = randf_range(0.2, 2.5)
	
	var light_tween = create_tween()
	light_tween.tween_property(lights, "modulate:a", 1.0, delay)

	await get_tree().create_timer(delay).timeout

	thunder_sound.pitch_scale = randf_range(0.8, 1.2)
	thunder_sound.play()
	
	thunder_sound.finished.connect(func():
		can_lighting = true
	, CONNECT_ONE_SHOT)

func strike_bolt():
	var area_size: Vector2 = background.size
	var scale_factor: float = area_size.x / background_realsize.x
	
	var start_x = randf_range(area_size.x * 0.15, area_size.x * 0.85)
	var start_y = area_size.y * 0.22
	var end_x = start_x + randf_range(-60.0, 60.0) * scale_factor
	var end_y = area_size.y * 0.54
	
	lighting_bolt.width = 2.0 * scale_factor
	lighting_bolt.points = generate_bolt_points(
		Vector2(start_x, start_y),
		Vector2(end_x, end_y),
		12,
		20.0 * scale_factor
	)
	lighting_bolt.modulate.a = 1.0
	lighting_bolt.visible = true

func generate_bolt_points(start_pos: Vector2, end_pos: Vector2, segments: int = 12, jag_amount: float = 20.0) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(start_pos)
	
	var direction = end_pos - start_pos
	var perpendicular = Vector2(-direction.y, direction.x).normalized()
	
	for i in range(1, segments):
		var progress = float(i) / float(segments)
		var base_point = start_pos + direction * progress
		var offset = randf_range(-jag_amount, jag_amount) * sin(progress * PI)
		points.append(base_point + perpendicular * offset)
		
	points.append(end_pos)
	return points

func update_lights():
	var proporcao = background.size / background_realsize
	lights.scale = proporcao