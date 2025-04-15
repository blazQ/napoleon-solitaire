extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/table.tscn")


func _on_settings_pressed() -> void:
	$Panel/MainMenuContainer.hide()
	$Panel/SettingsContainer.show()


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	$Panel/MainMenuContainer.show()
	$Panel/SettingsContainer.hide()
