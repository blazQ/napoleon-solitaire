extends "res://pile.gd"

const CARD_WIDTH: int = 2
# True = RIGHT
# False = LEFT
@export var GROWTH_DIRECTION: bool = true

func _modify_snap_point(increase: bool):
	increase = !increase if !GROWTH_DIRECTION else increase
	var pile_offset_sgn = pile_offset if increase else -pile_offset
	self.snap_point.x += pile_offset_sgn
	self.snap_point.y += pile_offset / 16

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
