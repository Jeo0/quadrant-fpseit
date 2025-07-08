extends CharacterBody3D

var g_player = null
var g_walkSpeed: float = 5.4
var g_attack: bool = false
var g_statemachine: String = "Walking"

const g_attackRange: float = 2.5

@export var player_nodepath: NodePath

@onready var navi_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_eat_anim: AnimatedSprite3D = $attack_eat_anim

func _ready() -> void:
	g_player = get_node(player_nodepath)
	# g_statemachine = attack_eat_anim.get("parameters/playback")
	attack_eat_anim.play("Walking")
	
func _process(delta: float) -> void:
	# add gravity
	# if !is_on_floor():
		# velocity += get_gravity() * delta
	velocity = Vector3(0,0,0)
	
	var m_isnear = _target_in_range()
	if m_isnear:
		if g_statemachine != "Attacking":
			g_statemachine = "Attacking"
			attack_eat_anim.show()
			attack_eat_anim.frame = 0
			attack_eat_anim.play("attack_eat") 					
			
			# hard look at the player's position
		look_at(Vector3(g_player.global_position.x, global_position.y, g_player.global_position.z), Vector3.UP, false)
	else: 
		if g_statemachine != "Walking":
			g_statemachine = "Walking"
			attack_eat_anim.show()
			attack_eat_anim.frame = 0
			attack_eat_anim.play("walking") 		
		
		navi_agent.set_target_position(g_player.global_transform.origin)
		var next_nav_point = navi_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * g_walkSpeed
		
		# soft/slow look at the player's position
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 3.0)
		
		
	
	
	
	move_and_slide()
	
	
func _target_in_range() -> bool:
	return global_position.distance_to(g_player.global_position) <= g_attackRange
