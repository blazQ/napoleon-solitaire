extends HSlider

@export var bus_name: String
var bus_index: int
var audio_settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = ConfigFileHandler.load_audio_settings()[bus_name]
	print("Setting initial value")
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
	
func _on_value_changed(value: float):
	print("Setting value to: ", str(value))
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
	ConfigFileHandler.save_audio_settings(bus_name, value)
