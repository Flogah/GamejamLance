extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var lanze: Node2D = $Lanze
var lance_up_angle = -135
var lance_down_angle = -45


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var speed:float = 150
@export var sprint_speed:float = 300
@export var accel:float = 10
@export var slowdown:float = 30


var current_speed:float = 0
@export var jump_velocity:float = 200

@export var looking_right:bool = true

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
	get_input(delta)
	move_and_slide()

func get_input(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	var sprint_input = Input.is_action_pressed("dash")
	lanze_lean(input_direction)
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

func face_direction(input_direction:float) -> void:
	if input_direction > 0:
		#turn to the right
		animated_sprite.flip_h = false
		if lanze.position.x > 0:
			lanze.position.x = -lanze.position.x
		pass
	elif  input_direction < 0:
		#turn to the left
		animated_sprite.flip_h = true
		if lanze.position.x < 0:
			lanze.position.x = -lanze.position.x
		pass
	else:
		pass

func lanze_lean(input_direction:float) -> void:
	if input_direction:
		var angle = lance_down_angle
		if input_direction < 0:
			angle = 90 - lance_down_angle
		lanze.rotation_degrees = move_toward(lanze.rotation_degrees, angle, 5)
	else:
		lanze.rotation_degrees = move_toward(lanze.rotation_degrees, lance_up_angle, 50)
