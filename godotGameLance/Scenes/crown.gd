extends Area2D

@onready var win_screen: ColorRect = $WinScreen
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var won:bool = false
var ascension_speed:float = 5

func _ready() -> void:
	win_screen.visible = false

func _on_body_entered(body: Node2D) -> void:
	win_screen.visible = true
	won = true

func _physics_process(delta: float) -> void:
	if won: animated_sprite.position.y = move_toward(animated_sprite.position.y, -80.0, ascension_speed*delta)
