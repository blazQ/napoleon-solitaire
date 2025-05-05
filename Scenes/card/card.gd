class_name Card extends Area3D

const CardConstants = preload(Strings.CARD_CONSTANTS)

# Card Data
@export var rank: CardConstants.Rank = CardConstants.Rank.ACE
@export var suit: CardConstants.Suit

# Card Dragging System
@export var is_selected: bool = false
@export var is_finalized: bool = false
@export var is_pile_top: bool = false

@export var is_hovered: bool = false
@export var is_snapping: bool = false
@export var is_floating: bool = false

@export var shine_material: Material = preload(Strings.CARD_SHINE)
@export var drop_particles: PackedScene = preload(Strings.DROP_PARTICLES)

@onready var front_mesh: MeshInstance3D = $CollisionShape3D/CardMeshFront
@onready var back_mesh: MeshInstance3D = $CollisionShape3D/CardMeshBack
@onready var woosh_sound: AudioStreamPlayer = $WooshSound
@onready var pop_sound: AudioStreamPlayer = $PopSound
@onready var push_sound: AudioStreamPlayer = $PushSound
var current_pile: Pile

# Events
signal card_hovered(card)
signal card_unhovered(card)

# Animation
var tween_up: Tween
var tween_down: Tween
var tween_hover: Tween
var tween_rot: Tween

var tween_original_position: Vector3
var tween_float_up_position: Vector3

const TRANS_FAST = 0.1
const TRANS_MEDIUM = 0.3
const TRANS_LONG = 0.6
const FLOAT_CONST = 0.4
const CARD_WIDTH = 2
const CARD_HEIGHT = 3
const MAX_ROTATION_DEG = 10


#region Setters
func set_rank_suit(p_rank: CardConstants.Rank = CardConstants.Rank.ACE, p_suit: CardConstants.Suit = CardConstants.Suit.SPADES):
		rank = p_rank
		suit = p_suit

func set_card_textures(frontface, backface):
	var front_tex = load(frontface) as Texture2D
	var back_tex = load(backface) as Texture2D
	
	if front_tex == null or back_tex == null:
		print("ERROR: Impossibile caricare le texture!")
		return
	
	var front_material = front_mesh.get_active_material(0)
	var back_material = back_mesh.get_active_material(0)
	  
	if front_material == null or back_material == null:
		print("ERROR: I materiali sono null!")
		return
	
	front_material.albedo_texture = front_tex
	back_material.albedo_texture = back_tex
#endregion

#region Selection
func toggle_selection():
	is_selected = !is_selected

	if is_selected:
		pop_sound.play()
	else:
		push_sound.play()

	_set_selection_shaders(null)
#endregion

# ----- Animations, SFX and GFX ------- #
#region Mouse Hovering
func _set_selection_shaders(next_pass: Material):
	front_mesh.material_override.next_pass = next_pass

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseMotion and (is_hovered or is_selected) and is_pile_top and !is_finalized:
		if is_floating and !tween_up.is_running():
			# Getting the local position of the mouse relative to the card's position
			var local_hit = global_transform.affine_inverse() * event_position
			# Clamping values so that it's 0 near the center, 1 or -1 depending on the side of the card
			var rel_x = clamp(local_hit.x / (CARD_WIDTH / 2), -1.0, 1.0)
			var rel_z = clamp(local_hit.z / (CARD_HEIGHT / 2), -1.0, 1.0)
			rotate_3d_card(rel_x, rel_z)

	if event is InputEventMouseButton:
		_reset_rotation()
		_elastic_scale_down()

func rotate_3d_card(rel_x: float = 0.0, rel_z: float = 0.0):
	if !is_hovered and !is_selected:
		_reset_rotation()

	var target_rotation = Vector3(+rel_z * MAX_ROTATION_DEG, 0, -rel_x * MAX_ROTATION_DEG)

	var rot_tween = create_tween()
	rot_tween.tween_property(self, "rotation_degrees", target_rotation, 0.1).set_trans(Tween.TRANS_SINE)

func on_card_hovered() -> void:
	if !is_selected and !is_snapping and is_pile_top and !is_finalized:
		is_hovered = true
		_set_selection_shaders(shine_material)
		if !is_floating:
			is_floating = true
			_float_card_up()
			_elastic_scale_up()
		rotate_3d_card()
	emit_signal("card_hovered", self)

func on_card_unhovered() -> void:
	if !is_selected and !is_snapping and is_pile_top and !is_finalized:
		is_hovered = false
		_set_selection_shaders(null)
		if is_floating:
			is_floating = false
			_float_card_down()
			_elastic_scale_down()
		rotate_3d_card()
	emit_signal("card_unhovered", self)

func _float_card_up():
	if is_floating:
		tween_up = create_tween()
		tween_up.tween_property(self, "position", tween_original_position + Vector3(0, 0.4, 0), 0.5).set_trans(Tween.TRANS_SINE)

func _float_card_down():
	tween_down = create_tween()
	tween_down.tween_property(self, "position", tween_original_position, 0.5).set_trans(Tween.TRANS_SINE)

func _reset_rotation():
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween()
	tween_rot.tween_property(self, "rotation_degrees", Vector3.ZERO, 0.3).set_trans(Tween.TRANS_SINE)
	return

func _elastic_scale_up():
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector3(1.1, 1.1, 1.1), TRANS_MEDIUM)

func _elastic_scale_down():
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector3.ONE, 0.55)

func spawn_drop_particles():
	var drop_particles_instance = drop_particles.instantiate()
	self.add_child(drop_particles_instance)
	drop_particles_instance.emitting = true
#endregion

#region Tweens and repositioning
func snap_to_position_with_animation(target_pos: Vector3, ease_type: Tween.EaseType, trans_type: Tween.TransitionType, duration: float = TRANS_MEDIUM):
	_stop_selection_tweens()
	is_snapping = true 
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(trans_type).set_ease(ease_type)
	tween.connect("finished", Callable(self, "_on_snap_finished"))

func _on_snap_finished() -> void:
	is_snapping = false
	if !is_selected:
		tween_original_position = position

func _stop_selection_tweens():
	if tween_up: tween_up.kill()
	if tween_down: tween_down.kill()
	is_floating = false
#endregion
