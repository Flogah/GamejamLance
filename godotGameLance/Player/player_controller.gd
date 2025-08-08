extends CharacterBody2D

@export var devmode:bool = false

# COMPONENTS
@onready var speedometer: Label = $Speedometer
@onready var lance: Node2D = $Lance

# GRAVITY
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_speed = 1000 #max fall speed

# JUMP N RUN
@export var walk_speed:float = 150
@export var spear_speed:float = 250
@export var sprint_speed:float = 700

@export var slow_accel:float = 2
@export var accel:float = 70

@export var jump_velocity:float = 250
var max_coyote_time:float = 0.1
var coyote_timer:float = 0.0
var lancejumped:bool = false

# VISUAL SENSE
@onready var downwards_raycast: RayCast2D = $DownwardsRaycast
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var looking_right:int = 1

# AUDIO
@onready var jump: AudioStreamPlayer2D = $Sounds/Jump
@onready var lance_swing: AudioStreamPlayer2D = $Sounds/LanceSwing
@onready var stab: AudioStreamPlayer2D = $Sounds/Stab

func _physics_process(delta: float) -> void:
	
	# align player with the floor
	if is_on_floor() and downwards_raycast.is_colliding():
		rotation = move_toward(rotation, downwards_raycast.get_collision_normal().angle() + PI/2, 5 * delta)
	# gravity
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
		
	_coyote_time(delta)
	
	get_input(delta)
	
	# update speedometer
	if devmode:
		speedometer.text = "Speed: " + str(velocity.x)
	
	set_floor_snap_length(4)
	move_and_slide()

func get_input(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	var sprint_input = Input.is_action_pressed("dash")
	
	lance.hold(looking_right, velocity, walk_speed, spear_speed)
	#region handle acceleration/speed
	if input_direction:
		face_direction(input_direction)
		
		# turn around fast while on the ground
		# no matter at what speed
		if is_on_floor():
			if velocity.x > 0 and input_direction < 0:
				velocity.x = velocity.x * -1
			if velocity.x < 0 and input_direction > 0:
				velocity.x = velocity.x * -1
		

		
		
		if sprint_input:
			# is input and speed point in the same direction?
			if (velocity.x > 0 and input_direction > 0) or (velocity.x < 0 and input_direction < 0):
				if is_on_floor():
					velocity.x = move_toward(velocity.x, sprint_speed * input_direction, slow_accel)
			else:
				velocity.x = move_toward(velocity.x, walk_speed * input_direction, accel)
		
		elif abs(velocity.x) < walk_speed + 1:
			# what happens while at walking speed
			velocity.x = move_toward(velocity.x, walk_speed * input_direction, accel)
		elif abs(velocity.x) > walk_speed + 1 and ((velocity.x > 0 and input_direction > 0) or (velocity.x < 0 and input_direction < 0)):
			velocity.x = move_toward(velocity.x, walk_speed * input_direction, accel)
	else:
		if is_on_floor():
			# no input, on the floor = slow down quickly
			velocity.x = move_toward(velocity.x, walk_speed * input_direction, accel)
		else:
			# no input, in the air = no change
			pass
	
	#endregion
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0:
			lancejumped = false
			jump.play()
			velocity.y = -jump_velocity  
			coyote_timer = -1
		else:
			lance_swing.play()
			lance.start_spin(looking_right)
	
	if Input.is_action_just_released("jump") or is_on_floor():
		lance.stop_spin()
	
	if Input.is_action_just_pressed("escape"):
		if devmode: get_tree().quit()
		else: find_parent("Main").open_main_menu()
	
	if devmode:
		if Input.is_action_just_pressed("increase_length"):
			lance.increase_length()
		if Input.is_action_just_pressed("decrease_length"):
			lance.decrease_length()

func _coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_timer = max_coyote_time
	else:
		coyote_timer -= delta

func face_direction(input_direction:float) -> void:
	if input_direction > 0:
		#turn to the right
		animated_sprite.flip_h = false
		looking_right = 1
	elif  input_direction < 0:
		#turn to the left
		animated_sprite.flip_h = true
		looking_right = -1
	else:
		pass

func find_catapult_vector(impact:Vector2) -> Vector2:
	var pos_imp = (position - impact)
	pos_imp = pos_imp * -looking_right
	pos_imp = pos_imp.orthogonal()
	
	return pos_imp.normalized()
