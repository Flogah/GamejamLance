extends Node2D

signal on_lance_collision(collider)

var up_angle = -90
var down_angle = 0
var spin_speed:float = 1600
var spinning:bool = false
@export var lance_length:float = 13

@onready var spinning_sprite: AnimatedSprite2D = $SpinningSprite
@onready var raycasts: Node2D = $Raycasts
@onready var spinning_area: Area2D = $SpinningArea
@onready var spinning_shape: CollisionShape2D = $SpinningArea/CollisionShape2D
var areas_in_range:Array
var bodies_in_range:Array

@onready var lanceSpritecontainer: Node2D = $LanceSprites
@onready var lanceSprite: Sprite2D = $LanceSprites/BaseLance
@onready var lancetip: RayCast2D = $Lancetip
var collision_object
var combat_mode:bool = false

var facing:int = 1

func _ready() -> void:
	spinning_sprite.visible = false

func _physics_process(delta: float) -> void:
	lance_colliding()

func lance_colliding():
	if lancetip.is_colliding(): emit_signal("on_lance_collision", lancetip.get_collider())
	
	if !spinning: return
	
	if !bodies_in_range.is_empty():
		for body in bodies_in_range:
			emit_signal("on_lance_collision", body)
	if !areas_in_range.is_empty():
		for area in areas_in_range:
			emit_signal("on_lance_collision", area)

	var collision_normals:Array
	var bounce_vector:Vector2 = Vector2.ZERO
	for ray in raycasts.get_children():
		if ray.is_colliding():
			var collider = ray.get_collider()
			var col_distance = ray.global_position.distance_to(ray.get_collision_point())
			var col_normal = ray.get_collision_normal()
			bounce_vector += col_normal * (ray.target_position.y / col_distance)
	if !get_parent().lancejumped:
		get_parent().lancejumped = true
		get_parent().velocity += bounce_vector.normalized() * 150 * log(lance_length)

func start_spin(in_direction:float) -> void:
	facing = in_direction
	spinning = true
	lanceSpritecontainer.visible = false
	spinning_sprite.visible = true

func hold(input_direction:float, velocity:Vector2, walk_speed:float, max_speed:float) -> void:
	var max_speed_percentage = clampf(inverse_lerp(walk_speed, max_speed, abs(velocity.x)), -1, 1)
	var target_rotation = up_angle
	if max_speed_percentage > 0:
		if input_direction > 0:
			target_rotation = lerp(-90, 0, max_speed_percentage)
		if input_direction < 0:
			target_rotation = lerp(-90, -180, max_speed_percentage)
	lanceSpritecontainer.rotation = deg_to_rad(target_rotation)
	lancetip.rotation = deg_to_rad(target_rotation - 90)

func stop_spin() -> void:
	spinning = false
	lanceSpritecontainer.visible = true
	spinning_sprite.visible = false

func increase_length() -> void:
	var sprite_addition = lanceSprite.duplicate()
	lance_length += 10
	sprite_addition.position.x = lance_length
	lanceSpritecontainer.add_child(sprite_addition)
	spinning_sprite.scale += Vector2.ONE * .1
	for ray in raycasts.get_children():
		ray.target_position.y += 10
	spinning_shape.shape.radius += 10

func decrease_length() -> void:
	lance_length -= 10
	for ray in raycasts.get_children():
		ray.target_position.y -= 10
	spinning_sprite.scale -= Vector2.ONE * .1
	if lanceSpritecontainer.get_children().size() > 1:
		lanceSpritecontainer.get_children().pop_back().queue_free()
	spinning_shape.shape.radius -= 10

func _on_spinning_area_area_entered(area: Area2D) -> void:
	areas_in_range.append(area)

func _on_spinning_area_area_exited(area: Area2D) -> void:
	areas_in_range.erase(area)

func _on_spinning_area_body_entered(body: Node2D) -> void:
	bodies_in_range.append(body)

func _on_spinning_area_body_exited(body: Node2D) -> void:
	bodies_in_range.erase(body)

func _on_lance_collision(collider: Variant) -> void:
	if !collider: return
	if collider.is_in_group("enemy"):
		collider.get_parent().die()
	elif collider.is_in_group("destructable"):
		collider.get_parent().explode()
		if spinning:
			get_parent().velocity.y = -400
