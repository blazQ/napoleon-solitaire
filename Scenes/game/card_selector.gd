class_name CardSelector extends Node3D

var controller_mode: bool = false

var selected_card: Card = null
var selection_point: Vector3

var selected_pile: Pile = null

var input_enabled: bool = false

const drag_plane_y: float = 1.3
const CARD_MASK := 2
const PILE_MASK := 1

var rotational_spring = 25.0
var rotational_damping = 5.0
var max_rotation_degrees = 15.0

# Position physics variables
var prev_position = Vector3.ZERO
var current_velocity = Vector3.ZERO

# Rotation physics variables
var rotation_displacement = 0.0  # x, y, z rotational displacement
var rotation_velocity = 0.0  # x, y, z rotational velocity


# TO DO: Controller Implementation

signal move_card(command)

func _on_solitaire_shuffling():
	input_enabled = false

func _on_solitaire_shuffling_end() -> void:
	input_enabled = true

func _try_select_card_mouse():
	var result = ray_cast(get_viewport().get_camera_3d(), CARD_MASK)
	if result and result.collider is Card and !result.collider.is_finalized and result.collider.is_pile_top:
		selected_card = result.collider
		selection_point = result.position
		selected_card.snap_to_position_with_animation(selection_point, Tween.EASE_IN, Tween.TRANS_QUAD, Card.TRANS_FAST)

func _try_select_card_controller():
	pass
	
func _try_select_card():
	if !controller_mode:
		_try_select_card_mouse()
	else:
		_try_select_card_controller()

	if selected_card:
		select_card(selected_card)

func _try_select_pile_mouse():
	var result = ray_cast(get_viewport().get_camera_3d(), PILE_MASK)
	if result and result.collider is Pile:
		selected_pile = result.collider
	else:
		selected_pile = selected_card.current_pile

func _try_select_pile_controller():
	pass

func _try_select_pile():
	if !controller_mode:
		_try_select_pile_mouse()
	else:
		_try_select_pile_controller()

	if selected_card.current_pile != selected_pile and selected_pile.is_move_allowed(selected_card):
		var command = MoveCardCommand.new(selected_card, selected_card.current_pile, selected_pile)
		emit_signal("move_card", command)
	else: 
		selected_card.snap_to_position_with_animation(selected_card.current_pile.snap_point, Tween.EASE_IN, Tween.TRANS_QUAD, Card.TRANS_MEDIUM)

	deselect_card()
	selected_card = null

func _process(delta: float) -> void:

	if !input_enabled:
		return

	if Input.is_action_just_pressed("select"):
		if selected_card == null:
			_try_select_card()
		else:
			_try_select_pile()
	if !controller_mode and selected_card and !selected_card.is_snapping:
		update_card_position()
		calculate_velocity(delta)
		apply_rotation_physics(delta)

func update_card_position():
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = cam.project_ray_origin(mouse_pos)
	var ray_direction = cam.project_ray_normal(mouse_pos)
	var plane_point = Vector3(0, drag_plane_y, 0)
	var intersection = ray_plane_intersection(ray_origin, ray_direction, plane_point, Vector3.UP)
	if intersection:
		prev_position = selected_card.global_transform.origin
		selected_card.global_transform.origin = intersection

func calculate_velocity(delta):
	if delta > 0:
		var position_change = selected_card.global_transform.origin - prev_position
		current_velocity = position_change / delta
		
		current_velocity = current_velocity.lerp(current_velocity, 0.7)

func apply_rotation_physics(delta):
	var speed = current_velocity.length()
	
	if speed > 0.1:  # Only apply rotation if there's significant movement
		# Calculate rotation target based on movement direction
		# We want rotation around Y axis based on the card's direction of movement
		
		# Get movement direction in XZ plane (ignoring Y component)
		var movement_xz = Vector2(current_velocity.x, current_velocity.z).normalized()
		
		# Calculate the "ideal" y rotation for this movement direction
		# This uses atan2 to get the angle from the movement vector
		var target_angle = atan2(-movement_xz.x, -movement_xz.y)
		
		# Scale by speed factor (faster movement = closer to target angle)
		var speed_factor = clamp(log(speed + 1) / 3.0, 0.0, 1.0)
		
		# Limit maximum rotation
		var max_rad = deg_to_rad(max_rotation_degrees)
		
		# Only rotate partially toward the movement direction based on speed
		var target_rotation = target_angle * speed_factor
		
		# Clamp to max rotation
		target_rotation = clamp(target_rotation, -max_rad, max_rad)
		
		# Apply spring-damper physics to rotation
		var rot_displacement = target_rotation - rotation_displacement
		var rot_force = (rotational_spring * rot_displacement) - (rotational_damping * rotation_velocity)
		rotation_velocity += rot_force * delta
		rotation_displacement += rotation_velocity * delta
		
		# Apply the Y rotation while keeping X and Z at 0
		selected_card.rotation = Vector3(0, rotation_displacement, 0)
	else:
		# If card is not moving much, gradually return to default orientation
		var rot_displacement = 0 - rotation_displacement
		var rot_force = (rotational_spring * rot_displacement) - (rotational_damping * rotation_velocity)
		rotation_velocity += rot_force * delta
		rotation_displacement += rotation_velocity * delta
		
		selected_card.rotation = Vector3(0, rotation_displacement, 0)

func select_card(card):
	current_velocity = Vector3.ZERO
	rotation_displacement = 0.0
	rotation_velocity = 0.0
	prev_position = card.global_transform.origin
	card.toggle_selection()

func deselect_card():
	if selected_card:
		# Smoothly reset rotation
		var reset_tween = create_tween()
		reset_tween.tween_property(selected_card, "rotation", Vector3.ZERO, 0.3).set_trans(Tween.TRANS_SINE)
		selected_card.toggle_selection()
		selected_card = null
		current_velocity = Vector3.ZERO
		rotation_displacement = 0.0
		rotation_velocity = 0.0
			
func ray_cast(camera, collision_mask = 1, max_distance = 1000):
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * max_distance
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	query.collide_with_areas = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	return result 

func ray_plane_intersection(ray_origin: Vector3, ray_direction: Vector3, plane_point: Vector3, plane_normal: Vector3):
	var denom = plane_normal.dot(ray_direction)
	if abs(denom) < 0.0001:
		return null  # The ray is parallel to the plane.
	var t = (plane_point - ray_origin).dot(plane_normal) / denom
	return ray_origin + ray_direction * t
