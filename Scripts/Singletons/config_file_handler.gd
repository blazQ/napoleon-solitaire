extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"



func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("video", "fullscreen", true)
		config.set_value("video", "crt", false)
		config.set_value("video", "shake", true)
		
		config.set_value("audio", "Master", 1.0)
		config.set_value("audio", "Sfx", 1.0)
		config.set_value("audio", "Music", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


func save_video_settings(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings


func save_audio_settings(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings
