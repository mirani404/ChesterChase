extends Node2D

@export var drop_scene = preload("res://scenes/cheese.tscn")
@export var trap_scene = preload("res://scenes/mouse_trap.tscn")
@export var portal_scene = preload("res://scenes/portal.tscn")
@export var drop_interval: float = 8.0
@export var trap_interval: float = 10.0
@export var portal_interval: float = 12.0
var time_left: float = 30.0
var portal_count: int = 0

func _ready() -> void:
	# Cheese drop timer
	var drop_timer = Timer.new()
	add_child(drop_timer)
	drop_timer.wait_time = drop_interval
	drop_timer.timeout.connect(spawn_drop)
	drop_timer.start()
	# Trap drop timer
	var trap_timer = Timer.new()
	add_child(trap_timer)
	trap_timer.wait_time = trap_interval
	trap_timer.timeout.connect(spawn_trap)
	trap_timer.start()
	# Portal timer
	var portal_timer = Timer.new()
	add_child(portal_timer)
	portal_timer.wait_time = portal_interval
	portal_timer.timeout.connect(spawn_portals)
	portal_timer.start()
	# Game countdown timer
	$Label.add_theme_font_size_override("font_size", 64)
	var game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = time_left
	game_timer.one_shot = true
	game_timer.timeout.connect(time_up)
	game_timer.start()

func _process(delta: float) -> void:
	time_left -= delta
	$Label.text = str(snappedf(time_left, 0.1)) + "s"

func spawn_drop() -> void:
	var screen = get_viewport_rect().size
	var obj = drop_scene.instantiate()
	add_child(obj)
	obj.position.x = randf_range(-screen.x, screen.x)
	obj.position.y = randf_range(-screen.y, screen.y)

func spawn_trap() -> void:
	var screen = get_viewport_rect().size
	var trap = trap_scene.instantiate()
	add_child(trap)
	trap.position.x = randf_range(-screen.x, screen.x)
	trap.position.y = randf_range(-screen.y, screen.y)

func spawn_portals() -> void:
	if portal_count >= 2:
		return
	var screen = get_viewport_rect().size
	var portal1 = portal_scene.instantiate()
	var portal2 = portal_scene.instantiate()
	add_child(portal1)
	add_child(portal2)
	portal1.position.x = randf_range(-screen.x, screen.x)
	portal1.position.y = randf_range(-screen.y, screen.y)
	portal2.position.x = randf_range(-screen.x, screen.x)
	portal2.position.y = randf_range(-screen.y, screen.y)
	portal1.linked_portal = portal2
	portal2.linked_portal = portal1
	portal_count = 2
	# Reset count when portals are used
	portal1.used.connect(on_portal_used)
	portal2.used.connect(on_portal_used)

func on_portal_used() -> void:
	portal_count = 0

func time_up() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/game_won.tscn")
