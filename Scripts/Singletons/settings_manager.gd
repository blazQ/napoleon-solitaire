extends Node

@onready var video_settings = ConfigFileHandler.load_video_settings()

var crt_filter_scene = preload("res://Scenes/crt_filter.tscn")
var crt_filter_instance : CanvasLayer

var fullscreen_enabled := true
var crt_enabled := false
var crt_pending := false

func _ready() -> void:
	fullscreen_enabled = video_settings["fullscreen"]
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	crt_enabled = video_settings["crt"]
	if crt_enabled:
		call_deferred("_add_crt_filter")

func set_crt_enabled():
	crt_enabled = !crt_enabled
	ConfigFileHandler.save_video_settings("crt", SettingsManager.crt_enabled)
	if crt_enabled:
		_add_crt_filter()
	else:
		_remove_crt_filter()

func _add_crt_filter():
	if crt_filter_instance == null:
		crt_filter_instance = crt_filter_scene.instantiate()
		assert(crt_filter_instance != null, "Errore: CRT Filter non istanziato!")
		get_tree().root.add_child(crt_filter_instance)
		crt_filter_instance.set_layer(100)
	print(crt_filter_instance)

func _remove_crt_filter():
	if crt_filter_instance != null:
		crt_filter_instance.queue_free()
		crt_filter_instance = null

func set_fullscreen():
	fullscreen_enabled = !fullscreen_enabled
	ConfigFileHandler.save_video_settings("fullscreen", SettingsManager.fullscreen_enabled)
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
