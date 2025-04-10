extends "res://pile.gd"

@export var suit: CardConstants.Suit

signal pile_filled()

func _on_card_pushed(card: Area3D, drop_zone: Area3D):
	super(card, drop_zone)
	if drop_zone == self:
		cards.front().get_node("CollisionShape3D").disabled = true
		cards.front().is_finalized = true
		if cards.size() == 10:
			emit_signal("pile_filled")
			print("pile filled!")

func is_move_allowed(card: Area3D) -> bool:
	if card.suit == suit:
		if !cards.is_empty():
			if card.rank == (cards.front().rank + 1) or (card.rank == 11 and cards.front().rank == 7):
				return true
			else:
				return false
		else: return true
	else: 
		return false
