class_name MoveCardCommand extends Command

var card: Card
var from_pile: Pile
var to_pile: Pile

func _init(p_card, p_from_pile, p_to_pile):
	card = p_card
	from_pile = p_from_pile
	to_pile = p_to_pile

func execute():
	print(card, " popped from ", from_pile, " and pushed to ", to_pile)
	if from_pile:
		from_pile.pop_card()
	to_pile.push_card(card)
	card.current_pile = to_pile
	card.snap_to_position_with_animation(to_pile.snap_point, Tween.EASE_IN_OUT, Tween.TRANS_QUAD, card.TRANS_MEDIUM)
	card.spawn_drop_particles()

func undo():
	to_pile.pop_card()
	from_pile.push_card(card)
	card.current_pile = from_pile
	card.snap_to_position_with_animation(from_pile.snap_point, Tween.EASE_IN_OUT, Tween.TRANS_QUAD, card.TRANS_MEDIUM)
	card.spawn_drop_particles()
