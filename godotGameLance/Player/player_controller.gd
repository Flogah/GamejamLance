extends CharacterBody2D

@export var devmode:bool = false



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_speed = 1000 #max fall speed

@onready var camera: Camera2D = $Camera2D


@export var walk_speed:float = 150
@export var sprint_speed:float = 700
@export var slow_accel:float = 2
@export var accel:float = 70
@export var decel:float = 70
@export var acceleration_curve:Curve
var looking_right:int = 1

var current_speed:float = 0

@export var jump_velocity:float = 350
@onready var lance: Node2D = $Lance
var lance_jump:float = 150
@export var toggle_lancemode:bool = true

# VISUAL
@onready var downwards_raycast: RayCast2D = $DownwardsRaycast
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# AUDIO
@onready var jump: AudioStreamPlayer2D = $Sounds/Jump
@onready var lance_swing: AudioStreamPlayer2D = $Sounds/LanceSwing
@onready var stab: AudioStreamPlayer2D = $Sounds/Stab

var max_coyote_time:float = 0.1
var coyote_timer:float = 0.0

func _physics_process(delta: float) -> void:
	
	# align player with the floor
	if is_on_floor() and downwards_raycast.is_colliding():
		rotation = move_toward(rotation, downwards_raycast.get_collision_normal().angle() + PI/2, 5 * delta)
	# gravity
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
		
	_coyote_time(delta)
	
	lance.hold(velocity, walk_speed, sprint_speed/3)

	get_input(delta)
	
	
	set_floor_snap_length(4)
	move_and_slide()

func get_input(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	var sprint_input = Input.is_action_pressed("dash")
	input_5(input_direction, sprint_input)
	
	# -----------------OTHER BUTTONS-----------------------
	if Input.is_action_just_pressed("escape"):
		find_parent("Main").open_main_menu()
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0:
			jump.play()
			velocity.y = -jump_velocity
			coyote_timer = -1
		else:
			lance_swing.play()
			lance.spin(looking_right)
	
	if Input.is_action_just_pressed("toggleMode"):
		if toggle_lancemode:
			toggle_lancemode = false
		else:
			toggle_lancemode = true
	
	if devmode:
		if Input.is_action_just_pressed("increase_length"):
			lance.increase_length()
		if Input.is_action_just_pressed("decrease_length"):
			lance.decrease_length()
	
	
#_____________INPUT System 1: Jank
func input_1(input_direction, sprint_input):
	var target_speed:float = 0.0
	if input_direction:
		if not sprint_input:
			animated_sprite.play("walk")
			if current_speed > walk_speed:
				current_speed = move_toward(current_speed, walk_speed, decel)
			else:
				current_speed = walk_speed
			animated_sprite.play("run")
			current_speed = move_toward(current_speed, sprint_speed, accel)
		velocity.x = input_direction * current_speed
		face_direction(input_direction)
	elif is_on_floor():
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, decel)
#_________INPUT System 2: Boring
func input_2(input_direction, sprint_input):
	var target_speed:float = 0.0
	if input_direction:
		face_direction(input_direction)
		if sprint_input:
			animated_sprite.play("run")
			target_speed = sprint_speed * input_direction
		else:
			animated_sprite.play("walk")
			target_speed = walk_speed * input_direction
	elif is_on_floor():
		animated_sprite.play("idle")
		target_speed = 0.0
	
	if abs(velocity.x) < walk_speed:
		velocity.x = move_toward(velocity.x, target_speed, accel)
	elif target_speed == 0.0:
		velocity.x = move_toward(velocity.x, target_speed, decel)
	else:
		velocity.x = move_toward(velocity.x, target_speed, slow_accel)
#_________INPUT System 3: Modified 1
func input_3(input_direction, sprint_input):
	var target_speed:float = 0.0
	if input_direction:
		if sprint_input:
			animated_sprite.play("run")
			target_speed = sprint_speed
		else:
			animated_sprite.play("walk")
			target_speed = walk_speed
		
		velocity.x = move_toward(velocity.x, input_direction * target_speed, accel)
		face_direction(input_direction)
		
	elif is_on_floor():
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0.0, decel)
#_________INPUT System 4: Curves
func input_4(input_direction, sprint_input):
	var walking_speed = acceleration_curve.get_point_position(0).x
	var running_speed = acceleration_curve.max_domain

	if input_direction:
		var target_speed = walking_speed
		if sprint_input:
			target_speed = running_speed
		
		var target_accel = acceleration_curve.sample(abs(velocity.x))
		
		velocity.x = move_toward(velocity.x, input_direction * target_speed, target_accel)
		face_direction(input_direction)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 70)

	if abs(velocity.x) > 0:
		animated_sprite.play("walk")
		if abs(velocity.x) > walking_speed:
			animated_sprite.play("run")
	else: animated_sprite.play("idle")
#_________INPUT System 5: More Control
func input_5(input_direction, sprint_input):
	var target_speed:float = 0.0
	var target_accel:float = accel
	
	if input_direction:
		face_direction(input_direction)
		target_speed = walk_speed * input_direction
		if sprint_input:
			target_speed = sprint_speed * input_direction
	else:
		target_speed = 0.0
	
	if is_on_floor():
		if abs(velocity.x) > walk_speed and input_direction:
			target_accel = slow_accel
		else:
			target_accel = accel
	else:
		target_accel = slow_accel
	
	velocity.x = move_toward(velocity.x, target_speed, target_accel)

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

func _on_lance_on_lance_collision(collider: Variant, collision_point: Vector2) -> void:
	if collider.is_in_group("enemy") and abs(velocity.x) >= sprint_speed/3:
		stab.play()
		collider.get_parent().die()
		return
	
	if collider.is_in_group("destructable"):
		if lance.spinning:
			velocity.y = -400.0
			collider.get_parent().explode()
		elif abs(velocity.x) >= sprint_speed/3: collider.get_parent().explode()
	
	
	if lance.spinning and collider.is_in_group("terrain"):
		if toggle_lancemode:
			if position.y < collision_point.y:
				velocity.y -= log(lance.lance_length) * lance_jump
		else:
			velocity += find_catapult_vector(collision_point) * log(lance.lance_length) * lance_jump
		return

func find_catapult_vector(impact:Vector2) -> Vector2:
	var pos_imp = (position - impact)
	pos_imp = pos_imp * -looking_right
	pos_imp = pos_imp.orthogonal()
	
	return pos_imp.normalized()

func _coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_timer = max_coyote_time
	else:
		coyote_timer -= delta
