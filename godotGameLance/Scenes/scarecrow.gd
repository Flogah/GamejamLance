extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var killzone_collision: CollisionShape2D = $Killzone/CollisionShape2D
@onready var body_collision: CollisionShape2D = $CharacterBody2D/CollisionShape2D
@onready var hitstop_timer: Timer = $HitstopTimer

func die() -> void:
	#print("I am vanquished!")
	animated_sprite.play("death")
	killzone_collision.disabled = true
	body_collision.disabled = true
	#Engine.time_scale = .2
	#hitstop_timer.start()

func _on_hitstop_timer_timeout() -> void:
	pass
	#Engine.time_scale = 1.0
