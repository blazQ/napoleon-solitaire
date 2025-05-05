extends Pile

@export var suit: CardConstants.Suit
@export var foundation: CardConstants.Rank
@export var capacity: int

signal pile_filled()

func push_card(card):
	super(card)
	cards.front().is_finalized = true
	emit_signal("shake", 0.4, 0.3)
	if cards.size() == capacity:
		emit_signal("pile_filled")

func flush():
	for card in cards:
		if card.rank != foundation:
			card.is_finalized = false
	super.flush()
	
