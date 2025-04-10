extends Label

@export var start_time: float
@export var elapsed_time: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = Time.get_time_string_from_unix_time(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().get_parent().game_started:
		elapsed_time = Time.get_unix_time_from_system() - start_time
		text = Time.get_time_string_from_unix_time(elapsed_time)


func _on_game_start_timeout() -> void:
	start_time = Time.get_unix_time_from_system()
