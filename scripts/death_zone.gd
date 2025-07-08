extends Area3D


@onready var timer: Timer = $Timer
@onready var control: Control = $Control


func _on_body_entered(body: Node3D) -> void:
	print("u foking died, respawning")
	# await get_tree().create_timer(1.0).timeout
	timer.start()


func _ready() -> void:
	control.hide()
	
func _on_timer_timeout() -> void:
	
	get_tree().reload_current_scene()
	# queue_free()
