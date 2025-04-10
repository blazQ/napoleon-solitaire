class_name Card extends Area3D

const CardConstants = preload("res://Scripts/card_constants.gd")

# Card Data
@export var rank: CardConstants.Rank = CardConstants.Rank.ACE
@export var suit: CardConstants.Suit

# Card Dragging System

@export var is_selected: bool = false
@export var is_finalized: bool = false
@export var is_pile_top: bool = false

@export var is_draggable: bool = false
@export var is_snapping: bool = false

var drag_plane_y: float = 0.0

var current_pile: Area3D
var last_pile: Area3D
var pending_zones: int

# Ray Casting Variables
const DIST: int = 1000

# Events
signal card_pushed(card, pile)
signal card_popped(card, pile)
signal move()

# Textures paths
var frontface : String
var backface : String

# Animation
const TRANS_FAST = 0.1
const TRANS_MEDIUM = 0.3
const TRANS_LONG = 0.6

# Init Functions

func set_card_values(chosen_value, chosen_suit):
	rank = chosen_value
	suit = chosen_suit
func set_card_texture_paths(chosen_frontface, chosen_backface):
	frontface = chosen_frontface
	backface = chosen_backface
func set_card_textures():
	var original_material = $CollisionShape3D/Pivot/CardMesh.material_override
	if original_material:

		var material = original_material.duplicate() as ShaderMaterial
		$CollisionShape3D/Pivot/CardMesh.material_override = material

		var front_texture_resource = load(frontface)
		var back_texture_resource = load(backface)
		
		material.set_shader_parameter("front_texture", front_texture_resource)
		material.set_shader_parameter("back_texture", back_texture_resource)

func _ready() -> void:
	for pile in get_tree().get_nodes_in_group("piles"):
		pile.card_entered.connect(_on_pile_card_entered)
		pile.card_exited.connect(_on_pile_card_exited)

# Main Process Function
func _process(_delta: float) -> void:
	if is_selected:
		drag_card()

# Collision Events Functions
func _toggle_selection():
	is_selected = !is_selected

func _on_mouse_entered() -> void:
	if not is_selected:
		is_draggable = true

func _on_mouse_exited() -> void:
	if not is_selected:
		is_draggable = false

func _on_pile_card_entered(card: Variant, pile: Area3D) -> void:
	if card == self and !self.is_snapping:
		pending_zones += 1
		print(self, "is over ", pile, " Pending Zones: ", pending_zones)
		if pile.is_move_allowed(card):
			current_pile = pile
		else : print("Droppable area doesn't accept this card!")

func _on_pile_card_exited(card: Variant, pile: Area3D) -> void:
		if card == self and !self.is_snapping:
			pending_zones -= 1
			print(self, "left ", pile, " Pending Zones: ", pending_zones)
			if pending_zones <= 0:
				current_pile = last_pile
				pending_zones = 0
			print(self, "left a droppable area!")
	
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
		if event is InputEventMouseButton:
			# If the user clicks 
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# We toggle selection
				_toggle_selection()
				# If by toggling we selected the card, we'll generate the popping event and snap to mouse cursor
				if is_selected:
					pop_from_current_pile()
					snap_to_mouse_cursor(event.position)
					pending_zones += 1
				# If by toggling we de-selected the card, we'll generate a pushing event and snap to pile.
				else:
					push_to_current_pile()
					# Card has been dropped in the current drop zone

func push_to_current_pile():
	# current_pile always contains either the last_pile (if the card isn't above a droppable area) 
	# or the droppable area the card is currently hovering
	snap_to_position_with_animation(current_pile.get_snap_point())
	if last_pile != current_pile:
		last_pile = current_pile
		emit_signal("move")
	print("Card Dropped: ", self)
	emit_signal("card_pushed", self, current_pile)
	$PushSound.play()

# Problem with clarity and implementation: using this method outside of this class is risky, because you can call it on a card which is not the top
# of a drop zone.
func pop_from_current_pile():
	print("Card Selected: ", self)
	emit_signal("card_popped", self, current_pile)
	$PopSound.play()
	
# ----- RayCasting and Geometrical Functions ------- #
func get_mouse_world_pos(mouse:Vector2):
	#The physics state of the world
	var space = get_world_3d().direct_space_state
	#start and end world positions for the ray
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse,DIST)
	#Params for 3D raycast
	#Alt var params = PhysicsRayQueryParameters3D.create(start,end)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	params.collide_with_areas = true
	params.collision_mask = ~ (1 << 1)  # This masks out layer 2 
	#cast the ray using the space and return the results as a Dictionary
	return space.intersect_ray(params)

func ray_plane_intersection(ray_origin: Vector3, ray_direction: Vector3, plane_point: Vector3, plane_normal: Vector3):
	var denom = plane_normal.dot(ray_direction)
	if abs(denom) < 0.0001:
		return null  # The ray is parallel to the plane.
	var t = (plane_point - ray_origin).dot(plane_normal) / denom
	return ray_origin + ray_direction * t

# ----- Animations and SFX------- #

func play_sound(sound: AudioStreamPlayer):
	sound.play()
	
func snap_to_mouse_cursor(mouse_2d_position: Vector2):
	var mouse_card_intersection = get_mouse_world_pos(mouse_2d_position)
	print(mouse_card_intersection)
	# The y plane along which the card will be dragged
	drag_plane_y = global_transform.origin.y # Candidate for repositioning
	# The flag disables drag update to animated the snapping to the cursor
	is_snapping = true  # disable drag updates
	# Tweening to animate
	var tween = create_tween()
	tween.tween_property(self, "global_position", mouse_card_intersection.position, TRANS_FAST).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished() -> void:
	is_snapping = false

func snap_to_position_with_animation(target_pos: Vector3, duration: float = TRANS_MEDIUM) -> void:
	is_snapping = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func drag_card():
	if !is_snapping:
		var cam = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = cam.project_ray_origin(mouse_pos)
		var ray_direction = cam.project_ray_normal(mouse_pos)
		var plane_point = Vector3(0, drag_plane_y, 0)  # Any point with Y equal to drag_plane_y
		var intersection = ray_plane_intersection(ray_origin, ray_direction, plane_point, Vector3.UP)
		if intersection:
			global_transform.origin = intersection
