extends Control

@onready var container: Control = $ScreenContainer

var current_screen: int = 0
var total_screens: int = 0
var screen_width: float

var touch_start := Vector2.ZERO
var is_dragging := false
var gesture_consumed := false
var active_tween: Tween

const DRAG_THRESHOLD := 30.0
const SWIPE_THRESHOLD := 0.20


func _ready() -> void:
	screen_width = size.x

	total_screens = container.get_child_count()

	for i in range(total_screens):
		var screen := container.get_child(i) as Control

		if screen == null:
			continue

		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.position = Vector2(i * screen_width, 0)
		screen.visible = true

	_update_active_screen()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			is_dragging = false
			gesture_consumed = false

			if active_tween and active_tween.is_running():
				active_tween.kill()
				gesture_consumed = true
		else:
			if is_dragging:
				var distance: float = event.position.x - touch_start.x
				_finish_swipe(distance)
			elif not gesture_consumed:
				_dispatch_tap(event.position)

			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		if touch_start.distance_to(event.position) > DRAG_THRESHOLD:
			is_dragging = true
			gesture_consumed = true

		if is_dragging:
			container.position.x += event.relative.x

		get_viewport().set_input_as_handled()

func _finish_swipe(distance: float) -> void:
	var threshold := screen_width * SWIPE_THRESHOLD

	if distance < -threshold:
		current_screen = min(current_screen + 1, total_screens - 1)
	elif distance > threshold:
		current_screen = max(current_screen - 1, 0)

	_snap_to_page(current_screen)

func _snap_to_page(index: int) -> void:
	var target_x = -index * screen_width

	if active_tween and active_tween.is_running():
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_QUINT)
	active_tween.set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		container,
		"position:x",
		target_x,
		0.4
	)

	active_tween.finished.connect(_update_active_screen)

func _update_active_screen() -> void:
	for i in range(total_screens):
		var screen := container.get_child(i) as Control

		if screen == null:
			continue

		if screen.has_method("clear"):
			screen.clear()

		if screen.has_method("set_active"):
			screen.set_active(i == current_screen)

		if screen.has_method("selected"):
			screen.selected(i == current_screen)

func _dispatch_tap(pos: Vector2) -> void:
	if total_screens == 0 or is_dragging:
		return

	var screen := container.get_child(current_screen) as Control

	if screen and screen.has_method("on_tap"):
		var local_pos := (
			screen.get_global_transform_with_canvas().affine_inverse()
			* pos
		)

		screen.on_tap(local_pos)
