class_name Central40 extends MoveRuleComponent

func is_move_allowed(card: Card, pile: Pile):
	if card.suit == pile.suit:
		if !pile.cards.is_empty():
			if card.rank == (pile.cards.front().rank + 1) or (card.rank == 11 and pile.cards.front().rank == 7):
				return true
			else:
				return false
		else: return true
	else: 
		return false
