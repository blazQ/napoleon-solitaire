class_name Lateral40 extends MoveRuleComponent

func is_move_allowed(card: Card, pile: Pile):
	if !pile.cards.is_empty():
		var front = pile.cards.front()
		if card.suit != front.suit and (card.rank == front.rank - 1 or (card.rank == 7 and front.rank == 11)):
			return true
		else: 
			return false
	else: return true
