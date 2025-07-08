extends CharacterBody3D


const g_walkSpeed: float = 5.0
const g_sprintSpeed: float = 14.
var g_currentSpeed: float = 0
var g_running: bool = false

const g_baseFOV: float = 80
const g_FOVchange: float = 1.5
const g_jumpVelocity: float = 4.5

# head bob
const DEFAULT_BOB_FREQUENCY: float = 1.23
const DEFAULT_BOB_AMPLITUDE: float = 0.081
const g_bobExponent: int = 4 		# make sure this is an even number
var g_bobFrequency: float = DEFAULT_BOB_FREQUENCY
# const g_bobFrequency: float = 30 # for debug
# const g_bobAmplitute: float = 0.07
var g_bobAmplitute: float = DEFAULT_BOB_AMPLITUDE
var m_bob_time: float = 1.0

# bullets
var g_bullet = load("res://scenes/bullet.tscn")
var g_bullet_instance = null

# menu controls
var g_escape: bool = false
const g_sensitivity: float = 0.0025
@onready var neck = $Neck
@onready var camera = $Neck/Camera3D
@onready var current_speed_label: Label = $"../UserInterface/Panel/currentSpeed_label"

@onready var shoot_animation: AnimationPlayer = $"Neck/Camera3D/Baril/AnimationPlayer"
@onready var gun_barrel: RayCast3D = $"Neck/Camera3D/Baril/RayCast3D"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * g_sensitivity)		# rotate left right
		camera.rotate_x(-event.relative.y * g_sensitivity)		# rotate up down
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(75))


func _physics_process(delta: float) -> void:
	# add escape for mouse
	if Input.is_action_just_pressed("escape"):
		g_escape = !g_escape
		
	if g_escape:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = g_jumpVelocity
		
		##################################################################
		# fix this
		##################################################################
		# add velocity a bit when jumping
		velocity.x += clamp(velocity.x, 0, 1) * 100
		velocity.z += clamp(velocity.z, 0, 1) * 100
		
		
	# handle sprint
	if Input.is_action_just_pressed("run"):
		g_currentSpeed = g_sprintSpeed
		g_bobAmplitute = 0.095
		g_bobFrequency = 1.32
		g_running = true
		
	
	# default reset the speed when stopped
	elif g_running == false:
		g_currentSpeed = g_walkSpeed 
		
	
	
	# print currentSpeed
	current_speed_label.text = "currentSpeed: " + str(velocity.length()).pad_decimals(3)
	
	
	# handle slide and crouch

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * g_currentSpeed
			velocity.z = direction.z * g_currentSpeed
		else:
			# velocity.x = move_toward(velocity.x, 0, g_currentSpeed)
			# velocity.z = move_toward(velocity.z, 0, g_currentSpeed)
			
			# for inertia
			# last arg of the lerp:
			# the higher the tighter movement / stricter
			# the lower, the more drifty the movement
			velocity.x = lerp(velocity.x, direction.x * g_currentSpeed, delta * 7.6)
			velocity.z = lerp(velocity.z, direction.z * g_currentSpeed, delta * 7.6) 
			
			# reset the bob
			g_bobAmplitute = DEFAULT_BOB_AMPLITUDE
			g_bobFrequency = DEFAULT_BOB_FREQUENCY
			g_running = false
	else:
		# inertia midair (slow down)
		velocity.x = lerp(velocity.x, direction.x * g_currentSpeed, delta * 2.89)
		velocity.z = lerp(velocity.z, direction.z * g_currentSpeed, delta * 2.89)
		
		
	# head bob
	camera.transform.origin = _headbob(delta, velocity)


	# FOV
	camera.fov = _camfov(camera, g_currentSpeed, delta)
	

	# handle shoot left click
	if Input.is_action_pressed("bangbang"):
		if !shoot_animation.is_playing():
			shoot_animation.play("fire_animation")
			
			g_bullet_instance = g_bullet.instantiate()
			g_bullet_instance.position = gun_barrel.global_position # position
			
			# set the bullet transformation origin as where the barrel is pointing at
			g_bullet_instance.transform.basis = gun_barrel.global_transform.basis 
			
			get_parent().add_child(g_bullet_instance) # add the bullet as a child of the map node


	move_and_slide()



func _headbob(delta: float, m_currentVelocity: Vector3):
	m_bob_time += delta * m_currentVelocity.length() * float(is_on_floor()) 
	var pos = Vector3(0,0,0)
	pos.y = pow(sin(m_bob_time * g_bobFrequency), g_bobExponent) * g_bobAmplitute
	# pos.y = (m_bob_time * g_bobFrequency) * g_bobAmplitute
	return pos
	
func _camfov(m_camera, m_speed: float, delta: float):
	var velocity_clamped = clamp(velocity.length(), 0.5, m_speed * 2)
	var target_fov = g_baseFOV + g_FOVchange * velocity_clamped
	return lerp(m_camera.fov, target_fov, delta * 8.0)
	
