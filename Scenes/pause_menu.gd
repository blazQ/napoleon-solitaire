extends Control

signal unpause()

var filter_enabled: bool = false
var fullscreen_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	emit_signal("unpause")


func _on_settings_pressed() -> void:
	$MarginContainer/PauseContainer.hide()
	$MarginContainer/SettingsContainer.show()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
