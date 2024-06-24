extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 6.8
const STEP_HEIGHT = 0.3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready
var look_horizontal: Node3D = $look_horizontal

@onready
var look_vertical: Node3D = $look_horizontal/look_vertical

var walk = false
var coyote_time := 0.0
var can_double_jump := false

@onready
var prev_origin = global_transform.origin

@onready
var next_origin = global_transform.origin

var view_angle := Vector3()

@onready

var blood_overlay = $blood

func _ready() -> void:
	floor_max_angle = 0.6
	pass

func _physics_process(delta: float) -> void:
	var swim = false
	if position.y < 1.0:
		walk = false
		swim = true
		if velocity.y < -3:
			velocity.y *= exp(-delta * 5.0)
		velocity.y *= exp(-delta * 2.0)
		velocity.y += (1.0 - position.y) * delta * 20.0
		
		if velocity.y < 0.1:
			can_double_jump = true
	
	if position.y < 0.0:
		blood_overlay.visible = true
		var brightness := exp(position.y)
		blood_overlay.color.r = brightness * 0.9
		blood_overlay.color.g = brightness * 0.42
		blood_overlay.color.b = brightness * 0.4
		blood_overlay.color.a = remap(position.y, 0.0, -0.3, 0.0, 1.0)
	else:
		blood_overlay.visible = false

	# Add the gravity.
	if walk:
		velocity.y = 0
		can_double_jump = false # no double jumping for you!
	else:
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (look_horizontal.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if walk:
		coyote_time = 0
	else:
		coyote_time += delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_time < 0.3:
		velocity.y = JUMP_VELOCITY
		walk = false
		coyote_time = 999.0
	elif Input.is_action_just_pressed("jump") and can_double_jump:
		can_double_jump = false
		velocity.y = JUMP_VELOCITY
		if direction:
			velocity *= Vector3(0, 1, 0)
			velocity += direction * 6.0
	
	var accel = 20.0
	var decel = 0.0
	var speed = 3.0
	
	if walk:
		accel = 100.0
		decel = 60.0
		speed = SPEED
	
	if swim:
		accel = 20.0
		decel = 12.0
		speed = 5.0

	var speed_horizontal := (velocity * Vector3(1, 0, 1)).length()
	var decel_fac: float = max(speed_horizontal - delta * decel, 0.0) / (speed_horizontal + 0.0001)
	velocity.x *= decel_fac
	velocity.z *= decel_fac

	if direction:
		var speed_in_axis = velocity.dot(direction.normalized())
		var target_speed = direction.length() * speed
		if speed_in_axis < target_speed:
			var accel_fac = min(target_speed - speed_in_axis, delta * accel)
			velocity += direction.normalized() * accel_fac

	if walk:
		move_and_collide(Vector3(0.0, STEP_HEIGHT, 0.0))

	move_and_slide()
	if is_on_floor(): walk = true

	if walk:
		var res := move_and_collide(Vector3(0.0, -STEP_HEIGHT * 2.0, 0.0))
		if res and res.get_normal().y > cos(floor_max_angle):
			walk = true
		else:
			walk = false
			# Redo this walk
			position = next_origin
			move_and_slide()

	prev_origin = next_origin
	next_origin = global_transform.origin


func _process(delta) -> void:
	look_horizontal.global_transform.origin = lerp(prev_origin, next_origin, Engine.get_physics_interpolation_fraction())
	
	view_angle.x = fmod(view_angle.x, PI * 2)
	view_angle.y = clamp(view_angle.y, -PI / 2, PI / 2)

	look_horizontal.rotation = Vector3(0, view_angle.x, 0)
	look_vertical.rotation = Vector3(view_angle.y, 0, 0)

var sensitivity := 0.003

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		get_viewport().set_input_as_handled()

		view_angle.x -= event.relative.x * sensitivity
		view_angle.y -= event.relative.y * sensitivity
		
		$look_horizontal/look_vertical/viewmodel._view_moved(-event.relative.x * sensitivity, -event.relative.y * sensitivity)
