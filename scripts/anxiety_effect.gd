extends ColorRect

var line_width: float
var elapsed: float
var drawing_speed: float

var effects: Array[Dictionary] = []

func add_effect(effect: Dictionary):
	effects.append(effect)

func clear_effects():
	effects.clear()

func configure(config: Dictionary) -> void:
	line_width = config.line_width
	elapsed = config.elapsed
	drawing_speed = config.drawing_speed

func _process(delta: float) -> void:
	for effect in effects:
		effect.time += delta
	
	queue_redraw()

func _draw() -> void:
	for effect in effects:
		var strands = effect.strands
		var center = effect.position
		var time = effect.time

		var remaining := int(time * drawing_speed)

		for line in strands:
			if remaining <= 0:
				break

			var count := mini(remaining, line.size())

			if count >= 2:
				var partial := PackedVector2Array()

				for i in range(count):
					partial.append(center + line[i])

				draw_polyline(partial, Color.BLACK, line_width, true)

			remaining -= line.size()

func smooth_curve(points: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array()

	for i in range(points.size() - 1):
		var p0 := points[maxi(i - 1, 0)]
		var p1 := points[i]
		var p2 := points[i + 1]
		var p3 := points[mini(i + 2, points.size() - 1)]

		for j in range(6):
			var t := float(j) / 6.0
			var t2 := t * t
			var t3 := t2 * t

			var point := 0.5 * (
				2.0 * p1 +
				(-p0 + p2) * t +
				(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
				(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
			)

			result.append(point)

	result.append(points[points.size() - 1])

	return result
