extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $StaticBody2D/AnimatedSprite2D
@onready var bubble_body: StaticBody2D = $StaticBody2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var respawn_timer: Timer = $RespawnTimer

func explode() -> void:
	animated_sprite.play("destroy")
	collision_shape.disabled = true
	respawn_timer.start()


func _on_respawn_timer_timeout() -> void:
	animated_sprite.play("hover")
	collision_shape.disabled = false
