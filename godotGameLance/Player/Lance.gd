extends Node2D

signal on_lance_collision(collider)

var up_angle = -90
var down_angle = 0
var spin_speed:float = 1600
var spinning:bool = false
@export var lance_length:float = 13

@onready var spinning_sprite: AnimatedSprite2D = $SpinningSprite
@onready var raycasts: Node2D = $Raycasts

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
	if !lancetip.is_colliding(): return
	emit_signal("on_lance_collision", lancetip.get_collider())

func spin(in_direction:float) -> void:
	facing = in_direction
	lanceSpritecontainer.visible = false
	spinning_sprite.visible = true
	
	var collision_normals:Array
	var colliding_rays:Array
	for ray in raycasts.get_children():
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("enemy"):
				pass
				
			if collider.is_in_group("destructable"):
				get_parent().velocity.y = -400.0
				collider.get_parent().explode()
				
			if collider.is_in_group("terrain"):
				colliding_rays.append(ray)
				var col_distance = ray.global_position.distance_to(ray.get_collision_point())
				var col_normal = ray.get_collision_normal()
				# shorter = bigger jump
				#collision_normals.append(col_normal * (ray.target_position.y / col_distance))
				# longer = bigger jump
				collision_normals.append(col_normal * (col_distance / ray.target_position.y))
	
	if colliding_rays:
		var bounce_vector:Vector2 = Vector2.ZERO
		for collision_normal in collision_normals:
			bounce_vector += collision_normal
		print(bounce_vector)
		get_parent().velocity += bounce_vector.normalized() * 250 * log(lance_length)
	

#func _on_lance_on_lance_collision(collider: Variant, collision_point: Vector2) -> void:
	#if collider.is_in_group("enemy") and abs(velocity.x) >= sprint_speed/3:
		#stab.play()
		#collider.get_parent().die()
		#return
	#
	#if collider.is_in_group("destructable"):
		#if lance.spinning:
			#velocity.y = -400.0
			#collider.get_parent().explode()
		#elif abs(velocity.x) >= sprint_speed/3: collider.get_parent().explode()
	#
	#
	#if lance.spinning and collider.is_in_group("terrain"):
		#if toggle_lancemode:
			#if position.y < collision_point.y:
				#velocity.y -= log(lance.lance_length) * lance_jump
		#else:
			#velocity += find_catapult_vector(collision_point) * log(lance.lance_length) * lance_jump
		#return

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
	lanceSpritecontainer.visible = true
	spinning_sprite.visible = false

func increase_length() -> void:
	var sprite_addition = lanceSprite.duplicate()
	lance_length += 10
	sprite_addition.position.x = lance_length
	lanceSpritecontainer.add_child(sprite_addition)
	#TODO: Increase spinningSprite as the length increases
	for ray in raycasts.get_children():
		ray.target_position.y += 10

func decrease_length() -> void:
	lance_length -= 10
	for ray in raycasts.get_children():
		ray.target_position.y -= 10
	if lanceSpritecontainer.get_children().size() > 1:
		lanceSpritecontainer.get_children().pop_back().queue_free()
