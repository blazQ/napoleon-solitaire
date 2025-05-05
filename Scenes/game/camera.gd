extends Camera3D

var noise = FastNoiseLite.new()
var noise_sample = Vector3.ZERO

# Shake properties
var trauma = 0.0  # Current shake intensity, between 0 and 1
var trauma_power = 2  # Trauma exponent for smooth falloff
var max_roll = 0.1  # Maximum rotation in radians (about 6 degrees)
var max_offset = 0.5  # Maximum position offset

# Decay control
var decay_rate = 0.8  # How quickly trauma reduces over time

# Original transform
var initial_rotation = Vector3.ZERO
var initial_position = Vector3.ZERO

func _ready():
	# Configure noise
	noise.seed = randi()
	noise.frequency = 0.5
	noise.fractal_octaves = 2
	
	# Store initial values
	initial_rotation = rotation
	initial_position = position

func _process(delta):
	if trauma > 0:
		# Reduce trauma over time
		trauma = max(trauma - decay_rate * delta, 0)
		
		# Calculate shake intensity with quadratic falloff
		var shake_intensity = trauma * trauma
		
		# Get noise sample based on time
		var time = Time.get_ticks_msec() / 1000.0
		noise_sample.x = noise.get_noise_2d(time * 100, 0) 
		noise_sample.y = noise.get_noise_2d(0, time * 100)
		noise_sample.z = noise.get_noise_2d(time * 100, time * 100)
		
		# Apply shake to rotation
		rotation.x = initial_rotation.x + max_roll * shake_intensity * noise_sample.x
		rotation.y = initial_rotation.y + max_roll * shake_intensity * noise_sample.y
		rotation.z = initial_rotation.z + max_roll * shake_intensity * noise_sample.z
		
		# Apply shake to position
		position.x = initial_position.x + max_offset * shake_intensity * noise_sample.x
		position.y = initial_position.y + max_offset * shake_intensity * noise_sample.y
		position.z = initial_position.z + max_offset * shake_intensity * noise_sample.z
	else:
		# Reset to original state when not shaking
		rotation = initial_rotation
		position = initial_position

# Add trauma to trigger or intensify shake
func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

# One-shot shake with configurable parameters
func shake(intensity=0.5, duration=0.5, decay_override=null):
	add_trauma(intensity)
	
	# Optional custom decay rate for this shake
	if decay_override != null:
		decay_rate = decay_override
	
	# Reset decay rate after duration
	if decay_override != null:
		await get_tree().create_timer(duration).timeout
		decay_rate = 0.8
