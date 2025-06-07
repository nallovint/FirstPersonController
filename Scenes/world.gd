extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Spawns
@onready var navigation_region = $NavigationRegion3D


var zombie = load("res://zombie.tscn")
var death_particles = load("res://zombie_dead_particles.tscn")
var instance

func _ready() -> void:
	randomize()
	connect("zombie_died", _on_zombie_died)

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
