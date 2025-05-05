extends Node3D

const CardScene = preload(Strings.CARD_SCENE)
const CardConstants = preload(Strings.CARD_CONSTANTS)

@export var rules: GameRuleComponent

@export var deck: Array[Card]
@export var foundation_cards : Dictionary[CardConstants.Suit, Card] 

## Building a deck based on the rules provided
func build_deck() -> Array[Card]:
	if deck.is_empty():
		for suit in rules.get_playing_suits():
			for rank in rules.get_playing_ranks():
				var card = CardScene.instantiate()
				card.set_rank_suit(rank, suit)
				deck.push_front(card)
	return deck

## Shuffling deck based on the rules provided
func shuffle_deck(deck: Array[Card]):
	if rules.get_shuffle_constraints()["random"]:
		deck.shuffle()
	return deck

## Building foundations based on the rules provided
func build_foundations(foundation_piles: Dictionary[CardConstants.Suit, Pile]) -> Dictionary[CardConstants.Suit, Card]:
	if foundation_cards.is_empty():
		var foundation: Dictionary[CardConstants.Suit, CardConstants.Rank] = rules.get_foundation_ranks()
		for suit in foundation:
			var card = CardScene.instantiate()
			card.set_rank_suit(foundation[suit], suit)
			card.current_pile = foundation_piles[suit]
			card.is_finalized = true
			foundation_cards[suit] = card
	return foundation_cards
