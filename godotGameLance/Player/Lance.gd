extends Area2D

var up_angle = -90
var down_angle = 0
var spin_speed:float = 1600
var spinning:bool = false
@onready var spin_timer: Timer = $SpinTimer
@export var lance_length:float = 13

@onready var spritecontainer: Node2D = $Sprites
@onready var sprite: Sprite2D = $Sprites/Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction

func _ready() -> void:
	lance_length = sprite.position.x

func spin(in_direction:float) -> void:
	spinning = true
	spin_timer.start()
	direction = in_direction

func hold(velocity:Vector2, max_speed:float) -> void:
	if spinning: return
	var max_speed_percentage = velocity.x / max_speed
	var target_rotation = up_angle + ((abs(up_angle) - abs(down_angle)) * max_speed_percentage)
	rotation = move_toward(rotation, deg_to_rad(target_rotation), spin_speed)

func _physics_process(delta: float) -> void:
	if spinning:
		rotation_degrees += direction * spin_speed * delta

func _on_spin_timer_timeout() -> void:
	spinning = false

func increase_length() -> void:
	var sprite_addition = sprite.duplicate()
	lance_length += 10
	sprite_addition.position.x = lance_length
	spritecontainer.add_child(sprite_addition)
	collision_shape.shape.size.x += 10
	collision_shape.position.x += 5
	

func decrease_length() -> void:
	lance_length -= 10
	collision_shape.shape.size.x -= 10
	collision_shape.position.x -= 5
	if spritecontainer.get_children().size() > 1:
		spritecontainer.get_children().pop_back().queue_free()
