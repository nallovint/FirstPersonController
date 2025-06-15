extends Node3D

const SPEED = 40.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var particles = $GPUParticles3D

var velocity = Vector3.ZERO

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	position += velocity * delta
	if ray_cast_3d.is_colliding():
		mesh_instance_3d.visible = false
		particles.emitting = true
		ray_cast_3d.enabled = false 
		if ray_cast_3d.get_collider().is_in_group("enemy"):
			ray_cast_3d.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
		

func set_velocity(target):
	look_at(target)
	velocity = position.direction_to(target) * SPEED

func _on_timer_timeout() -> void:
	queue_free()
