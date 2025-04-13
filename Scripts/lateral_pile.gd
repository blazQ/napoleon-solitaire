extends "res://Scripts/pile.gd"

var LateralDropZoneMarker = preload("res://Scenes/lateral_drop_zone_marker.tscn")

const lateral_marker_offset = 1.6
const CARD_WIDTH: int = 2
# True = RIGHT
# False = LEFT
@export var GROWTH_DIRECTION: bool = true

func _ready() -> void:
	super()
	if GROWTH_DIRECTION:
		$RightMarker.queue_free()
	else:
		$LeftMarker.queue_free()

func _modify_snap_point(increase: bool):
	var pile_offset_sgn = pile_offset if increase else -pile_offset
	self.snap_point.y += pile_offset_sgn / 64
	
	pile_offset_sgn = -pile_offset_sgn if !GROWTH_DIRECTION else pile_offset_sgn
	self.snap_point.x += pile_offset_sgn


func _modify_drop_shape(increase: bool):
	var collision_shape = $DropZoneShape
	var pile_offset_sgn = pile_offset if increase else -pile_offset
	var shape = collision_shape.shape
	shape.extents.x += pile_offset_sgn / 2

	if GROWTH_DIRECTION:
		collision_shape.global_transform.origin.x += pile_offset_sgn / 2
	else:
		collision_shape.global_transform.origin.x -= pile_offset_sgn / 2

func is_move_allowed(card: Area3D) -> bool:
	if !cards.is_empty():
		var front = self.cards.front()
		if card.suit != front.suit and (card.rank == front.rank - 1 or (card.rank == 7 and front.rank == 11)):
			return true
		else: 
			return false
	else: return true
