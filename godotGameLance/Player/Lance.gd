extends Node2D

signal on_lance_collision(collider, collision_point)

var up_angle = -90
var down_angle = 0
var spin_speed:float = 1600
var spinning:bool = false
@onready var spin_timer: Timer = $SpinTimer
@export var lance_length:float = 13

@onready var spritecontainer: Node2D = $Sprites
@onready var sprite: Sprite2D = $Sprites/Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D
var collision_object

var facing:int = 1

func _ready() -> void:
	lance_length = sprite.position.x

func spin(in_direction:float) -> void:
	spinning = true
	spin_timer.start()
	facing = in_direction

func hold(velocity:Vector2, max_speed:float) -> void:
	if spinning: return
	var max_speed_percentage = velocity.x / max_speed
	var target_rotation = up_angle + ((abs(up_angle) - abs(down_angle)) * max_speed_percentage)
	rotation = move_toward(rotation, deg_to_rad(target_rotation), spin_speed)

func _physics_process(delta: float) -> void:
	if spinning:
		rotation_degrees += facing * spin_speed * delta
	
	if ray_cast.is_colliding():
		if ray_cast.get_collider() != collision_object:
			collision_object = ray_cast.get_collider()
			var collision_point = ray_cast.get_collision_point()
			emit_signal("on_lance_collision", collision_object, collision_point)
	elif collision_object != null:
		collision_object = null

func _on_spin_timer_timeout() -> void:
	spinning = false

func increase_length() -> void:
	var sprite_addition = sprite.duplicate()
	lance_length += 10
	sprite_addition.position.x = lance_length
	spritecontainer.add_child(sprite_addition)
	ray_cast.target_position.y += 10

func decrease_length() -> void:
	lance_length -= 10
	ray_cast.target_position.y -= 10
	if spritecontainer.get_children().size() > 1:
		spritecontainer.get_children().pop_back().queue_free()
