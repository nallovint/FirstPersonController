extends Node3D

@onready var hit_rect = $CanvasLayer/UI/ColorRect
@onready var spawns = $Spawns
@onready var navigation_region = $NavigationRegion3D

@onready var crosshair = $CanvasLayer/UI/TextureRect
@onready var crosshair_hit = $CanvasLayer/UI/TextureRect2


var zombie = load("res://zombie.tscn")
var death_particles = load("res://zombie_dead_particles.tscn")
var instance

func _ready() -> void:
	randomize()
	crosshair.position.x = get_viewport().size.x / 2 - 32
	crosshair.position.y = get_viewport().size.y / 2 - 32
	crosshair_hit.position.x = get_viewport().size.x / 2 - 32
	crosshair_hit.position.y = get_viewport().size.y / 2 - 32

func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	
func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawn_point
	navigation_region.add_child(instance)

func _on_zombie_died(pos):
	var particle_spawn = death_particles.instantiate()
	particle_spawn.position = pos
	add_child(particle_spawn)

func _on_enemy_hit():
	print("hit enemy")
	crosshair_hit.visible = true
	await get_tree().create_timer(0.05).timeout
	crosshair_hit.visible = false
