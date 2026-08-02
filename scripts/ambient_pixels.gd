extends Control

const PARTICLE_COUNT := 36

var particles: Array[Dictionary] = []
var elapsed := 0.0


func _ready() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 924_721
	for index in PARTICLE_COUNT:
		particles.append({
			"position": Vector2(random.randf(), random.randf_range(0.08, 0.88)),
			"speed": random.randf_range(0.006, 0.018),
			"phase": random.randf_range(0.0, TAU),
			"size": random.randi_range(1, 3),
			"warm": index % 5 == 0,
		})


func _process(delta: float) -> void:
	elapsed += delta
	for particle in particles:
		particle.position.x += particle.speed * delta
		if particle.position.x > 1.03:
			particle.position.x = -0.03
	queue_redraw()


func _draw() -> void:
	for particle in particles:
		var flicker: float = 0.35 + (sin(elapsed * 2.4 + particle.phase) + 1.0) * 0.25
		var drift_y: float = sin(elapsed * 0.8 + particle.phase) * 5.0
		var pixel_position := Vector2(particle.position.x * size.x, particle.position.y * size.y + drift_y)
		var color := Color(1.0, 0.95, 0.62, flicker) if particle.warm else Color(0.82, 0.96, 1.0, flicker)
		var pixel_size: float = particle.size
		draw_rect(Rect2(pixel_position, Vector2(pixel_size, pixel_size)), color)
		if particle.size == 3 and flicker > 0.7:
			draw_rect(Rect2(pixel_position + Vector2(-2, 1), Vector2(7, 1)), Color(color, flicker * 0.45))
			draw_rect(Rect2(pixel_position + Vector2(1, -2), Vector2(1, 7)), Color(color, flicker * 0.45))
