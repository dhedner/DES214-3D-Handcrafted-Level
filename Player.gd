class_name Player
extends CharacterBody3D

@export var speed = 6.0
@export var acceleration = 8.0
@export var jump_velocity = 5.5
@export var double_jump_velocity = 4.5
@export var smoothing_speed = 12.0
@export var camera_sensitivity = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumps = 0
var is_jumping = false

@onready var model = $PlayerRig
@onready var camera_rig = $CameraRig
@onready var spring_arm = $CameraRig/SpringArm3D

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Check movement input
	get_move_input(delta)

	move_and_slide()

	get_jump_input()


func get_move_input(delta):
	# Get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, camera_rig.rotation.y)
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, smoothing_speed * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, smoothing_speed * delta)
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-velocity.x, -velocity.z), smoothing_speed * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0 * speed, smoothing_speed * delta)
		velocity.z = lerp(velocity.z, 0.0 * speed, smoothing_speed * delta)
		
func get_jump_input():
	if is_on_floor():
		jumps = 0
	
	if Input.is_action_just_pressed("jump") and jumps < 2:
		if jumps == 0 or (jumps == 1 and !is_jumping):
			if (jumps == 0):
				velocity.y = jump_velocity
			else:
				velocity.y = double_jump_velocity
			jumps += 1
			is_jumping = true
	
	if is_on_floor():
		is_jumping = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate the camera's spring arm in response to mouse movement
		camera_rig.rotate_y(-event.relative.x * camera_sensitivity)
		spring_arm.rotate_x(-event.relative.y * camera_sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
