extends Node3D

const g_bullet_speed: float = 40.0
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var raycast: RayCast3D = $RayCast3D
@onready var particles: GPUParticles3D = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-g_bullet_speed) * delta
	if raycast.is_colliding():
		mesh.visible = false
		particles.emitting = true
		# raycast.enabled = false
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
