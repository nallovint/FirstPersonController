extends MeshInstance3D

var alpha = 1.0

@onready var blood = $Blood
@onready var terrain = $Brown

func _ready() -> void:
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

func init(pos1, pos2) -> void:
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(pos1)
	draw_mesh.surface_add_vertex(pos2)
	draw_mesh.surface_end()
	
func _process(delta: float) -> void:
	alpha -= delta * 3.5
	material_override.albedo_color.a = alpha

func _on_timer_timeout() -> void:
	queue_free()

func trigger_particles(pos, gun_pos, on_enemy):
	if on_enemy:
		blood.position = pos
		blood.look_at(gun_pos)
		blood.emitting = true
	else:
		terrain.position = pos
		terrain.look_at(gun_pos)
		terrain.emitting = true
