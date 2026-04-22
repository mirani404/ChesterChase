extends CharacterBody2D
const SPEED = 300.0
const STUCK_THRESHOLD = 2.0
const STUCK_DISTANCE = 5.0
const SHAKE_DURATION = 0.5
const SHAKE_INTENSITY = 10.0

var last_position: Vector2
var stuck_timer: float = 0.0
var is_shaking: bool = false
var shake_timer: float = 0.0
var origin_position: Vector2

func _ready() -> void:
	last_position = global_position

func _physics_process(delta: float) -> void:
	var target = $"../Marty"

	if is_shaking:
		shake_timer += delta
		$Sprite2D.position.x = sin(shake_timer * 40.0) * SHAKE_INTENSITY
		if shake_timer >= SHAKE_DURATION:
			$Sprite2D.position.x = 0.0
			global_position += (target.global_position - global_position).normalized() * 300.0
			is_shaking = false
			shake_timer = 0.0
			stuck_timer = 0.0
		return

	var direction = (target.position - position).normalized()
	velocity = direction * SPEED
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == target:
			game_over()

	if global_position.distance_to(last_position) < STUCK_DISTANCE:
		stuck_timer += delta
		if stuck_timer >= 1.0:
			$Sprite2D.texture = preload("res://sprites/chesterAngry.webp")
		if stuck_timer >= STUCK_THRESHOLD and not is_shaking:
			is_shaking = true
			shake_timer = 0.0
	else:
		stuck_timer = 0.0
		last_position = global_position
		$Sprite2D.texture = preload("res://sprites/chesterNeutral.webp")

func game_over() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/game_over.tscn")
