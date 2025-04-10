extends Area3D

const CardConstants = preload("res://Scripts/card_constants.gd")

@export var snap_point: Vector3
@export var cards: Array
@export var pile_offset: float = 0.05
@export var initial_half_width: float = 0.5

signal card_entered(card, zone)
signal card_exited(card, zone)

signal push_ended()
signal pop_ended()

func _ready() -> void:
	snap_point = global_transform.origin
	for table in get_tree().get_nodes_in_group("manager"):
		table.card_instanced.connect(_on_card_instanced)

func _on_card_instanced(card):
		card.card_pushed.connect(_on_card_pushed)
		card.card_popped.connect(_on_card_popped)
	
func _on_area_entered(area: Area3D) -> void:
	if area is Card and area.is_selected:
		emit_signal("card_entered", area, self)

func _on_area_exited(area: Area3D) -> void:
	if area is Card and area.is_selected:
		emit_signal("card_exited", area, self)
		
func _on_card_pushed(card: Area3D, pile: Area3D):
	if pile == self:
		print("Card pushed on ", self)
		if !cards.is_empty():
			cards.front().is_pile_top = false
	
		card.is_pile_top = true
		cards.push_front(card)
		
		_modify_drop_shape(true)
		_modify_snap_point(true)
		emit_signal("push_ended")

func _on_card_popped(_card: Area3D, pile: Area3D):
	if pile == self:
		print("Card popped from ", self)

		var previous_top = cards.pop_front()
		previous_top.is_pile_top = false
		
		if !cards.is_empty():
			cards.front().is_pile_top = true
	
		_modify_drop_shape(false)
		_modify_snap_point(false)
		emit_signal("pop_ended")

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

func is_move_allowed(_card: Area3D) -> bool:
	return true

func get_snap_point():
	return snap_point
