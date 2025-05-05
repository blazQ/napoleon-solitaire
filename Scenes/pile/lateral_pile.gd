extends Pile

var LateralDropZoneMarker = preload(Strings.DROP_ZONE_MARKER)

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

func push_card(card: Card):
	super.push_card(card)
	emit_signal("shake", 0.2, 0.1)
	
func _modify_snap_point(increase: bool):
	var pile_offset_sgn = pile_offset if increase else -pile_offset
	self.snap_point.y += pile_offset_sgn / 64
	
	pile_offset_sgn = -pile_offset_sgn if !GROWTH_DIRECTION else pile_offset_sgn
	self.snap_point.x += pile_offset_sgn


func _modify_drop_shape(increase: bool):
	var pile_offset_sgn = pile_offset if increase else -pile_offset
	collision_shape.extents.x += pile_offset_sgn / 2

	if GROWTH_DIRECTION:
		collision_shape_node.global_transform.origin.x += pile_offset_sgn / 2
	else:
		collision_shape_node.global_transform.origin.x -= pile_offset_sgn / 2
