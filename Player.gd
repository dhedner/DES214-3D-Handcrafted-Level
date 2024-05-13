extends CharacterBody3D
class_name Player

@export var speed = 5.0
@export var acceleration = 8.0
@export var jump_velocity = 4.5
@export var rotation_speed = 12.0
@export var camera_sensitivity = 0.0015

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Check movement input
	get_move_input(delta)

	move_and_slide()
	
	# Turn player towards the direction they're walking
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)

func get_move_input(delta):
	# Temporarily zero-out y velocity to set direction to horizontal motion
	var vy = velocity.y
	velocity.y = 0
	
	# Get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	velocity.y = vy

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate the camera's spring arm in response to mouse movement
		spring_arm.rotation.x -= event.relative.y * camera_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * camera_sensitivity
