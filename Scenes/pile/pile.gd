extends Area3D
class_name Pile

const CardConstants = preload(Strings.CARD_CONSTANTS)

@export var rule_component: MoveRuleComponent
@export var snap_point: Vector3
@export var cards: Array[Card]
@export var pile_offset: float = 0.05
@onready var collision_shape_node = $DropZoneShape
@onready var shape_original_position = $DropZoneShape.global_transform.origin
@onready var collision_shape = $DropZoneShape.shape
@onready var original_extents = collision_shape.extents

signal card_entered(card, zone)
signal card_exited(card, zone)
signal shake(duration, frequency, amplitude)

signal push_ended()
signal pop_ended()

func _ready() -> void:
	snap_point = global_transform.origin
	
func _on_area_entered(area: Area3D) -> void:
	if area is Card and area.is_selected:
		emit_signal("card_entered", area, self)

func _on_area_exited(area: Area3D) -> void:
	if area is Card and area.is_selected:
		emit_signal("card_exited", area, self)
		
func push_card(card: Card):
	if !cards.is_empty():
		cards.front().is_pile_top = false

	card.is_pile_top = true
	cards.push_front(card)
	
	_modify_drop_shape(true)
	_modify_snap_point(true)
	emit_signal("push_ended")

func pop_card():
	var previous_top = null
	if !cards.is_empty():
		previous_top = cards.pop_front()
		previous_top.is_pile_top = false
		
		if !cards.is_empty():
			cards.front().is_pile_top = true

		_modify_drop_shape(false)
		_modify_snap_point(false)
	emit_signal("pop_ended")
	return previous_top

func _modify_snap_point(increase: bool):
	if increase:
		self.snap_point.y += pile_offset
	else:
		self.snap_point.y -= pile_offset

func _modify_drop_shape(increase: bool):
	if increase:
		pass
	else:
		pass

func _reset_drop_shape():
	collision_shape_node.global_transform.origin = shape_original_position
	collision_shape.extents = original_extents
	

func is_move_allowed(_card: Card) -> bool:
	return rule_component.is_move_allowed(_card, self)

func flush():
	snap_point = global_transform.origin
	cards.clear()
	_reset_drop_shape()
