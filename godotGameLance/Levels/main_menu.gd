extends Node2D

const LEVEL_1 = preload("res://Levels/level_1.tscn")
const LEVEL_TEST = preload("res://Levels/level_test.tscn")
const MAIN_MENU = preload("res://Levels/main_menu.tscn")

func _on_level_1_pressed() -> void:
	var level1_instance = LEVEL_1.instantiate()
	get_parent().add_child(level1_instance)
	queue_free()

func _on_devtest_pressed() -> void:
	var devtest_instance = LEVEL_TEST.instantiate()
	get_parent().add_child(devtest_instance)
	queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()
