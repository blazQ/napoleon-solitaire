extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_reshuffle_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/table.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_solitaire_ui_update_move_count(move_count: Variant) -> void:
	$MenuPanel/ScoreTime/MoveCount.text = "Moves: " + str(move_count)


func _on_solitaire_ui_update_time(elapsed_time: Variant) -> void:
	$MenuPanel/ScoreTime/ElapsedTimeLabel.text = Time.get_time_string_from_unix_time(elapsed_time)
