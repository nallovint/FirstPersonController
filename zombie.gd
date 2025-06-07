extends CharacterBody3D

#var player = null
var state_machine

const SPEED = 4.0
const ATTACK_RANGE = 2.5

@onready var player = $"../../Player"

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree : AnimationTree = $AnimationTree

func _ready():
	#player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			#look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
	
	anim_tree.set("parameters/conditions/attacking", _target_in_range())
	anim_tree.set("parameters/conditions/running", !_target_in_range())
	
	
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
