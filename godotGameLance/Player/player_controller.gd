extends CharacterBody2D

@export var devmode:bool = false

@export var toggle_lancemode:bool = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_speed = 1000 #max fall speed

@onready var camera: Camera2D = $Camera2D


@export var speed:float = 150
@export var sprint_speed:float = 700
@export var accel:float = 2
@export var slowdown:float = 30
var looking_right:int = 1

var current_speed:float = 0
@export var jump_velocity:float = 150
@onready var lance: Node2D = $Lance
var lance_jump:float = 150

@onready var downwards_raycast: RayCast2D = $DownwardsRaycast

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var max_coyote_time:float = 0.1
var coyote_timer:float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if abs(velocity.x) > speed:
		camera.position.x += log(abs(velocity.x))/10 * looking_right
	else:
		camera.position.x = 0

func _physics_process(delta: float) -> void:
	#gravity
	if is_on_floor() and downwards_raycast.is_colliding():
		rotation = move_toward(rotation, downwards_raycast.get_collision_normal().angle() + PI/2, 5 * delta)
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
 		
		
	_coyote_time(delta)
	
	lance.hold(velocity, speed, sprint_speed/3)

	get_input(delta)
	
	
	set_floor_snap_length(4)
	move_and_slide()

func get_input(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	var sprint_input = Input.is_action_pressed("dash")
	
	if Input.is_action_just_pressed("escape"):
		find_parent("Main").open_main_menu()
	
	if input_direction:
		if not sprint_input:
			animated_sprite.play("walk")
			if current_speed > speed:
				current_speed = move_toward(current_speed, speed, slowdown)
			else:
				current_speed = speed
		else:
			animated_sprite.play("run")
			current_speed = move_toward(current_speed, sprint_speed, accel)
		velocity.x = input_direction * current_speed
		face_direction(input_direction)
	elif is_on_floor():
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, slowdown)
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0:
			velocity.y = -jump_velocity
			coyote_timer = -1
		else:
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
