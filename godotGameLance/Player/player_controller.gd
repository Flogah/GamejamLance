extends CharacterBody2D


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var speed:float = 150
@export var sprint_speed:float = 400
@export var accel:float = 2
@export var slowdown:float = 30

var current_speed:float = 0
@export var jump_velocity:float = 200

@export var looking_right:bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var lance: Area2D = $Lance


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	lance.hold(velocity, sprint_speed)

	get_input(delta)
	move_and_slide()

func get_input(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	var sprint_input = Input.is_action_pressed("dash")
	
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
	else:
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
	elif Input.is_action_just_pressed("jump"):
		if velocity.x < 0:
			lance.spin(-1)
		else:
			lance.spin(1)
	
	if Input.is_action_just_pressed("increase_length"):
		lance.increase_length()
	if Input.is_action_just_pressed("decrease_length"):
		lance.decrease_length()
	

func face_direction(input_direction:float) -> void:
	if input_direction > 0:
		#turn to the right
		animated_sprite.flip_h = false
		pass
	elif  input_direction < 0:
		#turn to the left
		animated_sprite.flip_h = true
		pass
	else:
		pass

func _on_lance_body_entered(body: Node2D) -> void:
	if not lance.spinning: return
	
	var collision_info = lance.get_last_slide_collision()
	if collision_info:
		print(find_catapult_vector(collision_info.get_position))
	
	
	
	if body.is_in_group("terrain"):
		velocity.y -= lance.lance_length * 15
		if velocity.x > 0:
			velocity.x += lance.lance_length * 15
		elif velocity.x < 0:
			velocity.x -= lance.lance_length * 15
		
	if body.is_in_group("enemy"):
		body.queue_free()

func find_catapult_vector(impact:Vector2) -> Vector2:
	return position - impact


func _on_lance_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.get_parent().queue_free()
