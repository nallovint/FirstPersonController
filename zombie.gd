extends CharacterBody3D

#var player = null
var state_machine
var health = 10

signal zombie_died
signal zombie_hit

const SPEED = 4.0
const ATTACK_RANGE = 2.5
const ATTACK_COOLDOWN = 1.0

@onready var player = $"../../Player"
@onready var world_path = $"../.."

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var attack_cooldown_timer = $AttackCooldownTimer

var can_attack = true

func _ready():
	#player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	attack_cooldown_timer.wait_time = ATTACK_COOLDOWN
	attack_cooldown_timer.one_shot = true # Ensure it's a one-shot timer
	attack_cooldown_timer.autostart = false # Don't start automatically

	# Connect the timer's timeout signal
	attack_cooldown_timer.connect("timeout", _on_attack_cooldown_timer_timeout)
	zombie_died.connect(world_path._on_zombie_died)
	zombie_hit.connect(world_path._on_enemy_hit)
	
func _process(delta):
	velocity = Vector3.ZERO
	
	var target_in_range = _target_in_range()
	
	match state_machine.get_current_node():
		"run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			#look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
	var should_attack = target_in_range and can_attack
	anim_tree.set("parameters/conditions/attacking", should_attack)
	anim_tree.set("parameters/conditions/running", !should_attack)
	
	
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		can_attack = false
		attack_cooldown_timer.start()
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func _on_attack_cooldown_timer_timeout():
	can_attack = true


func _on_area_3d_body_part_hit(dmg) -> void:
	health -= dmg
	emit_signal("zombie_hit")
	if health <= 0:
		emit_signal("zombie_died", position)
		queue_free()
