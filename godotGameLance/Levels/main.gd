extends Node2D

const MAIN_MENU = preload("res://Levels/main_menu.tscn")

func open_main_menu() -> void:
	get_child(0).queue_free()
	var menu_instance = MAIN_MENU.instantiate()
	add_child(menu_instance)
