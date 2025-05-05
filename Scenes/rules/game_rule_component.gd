class_name GameRuleComponent extends Node

const CardConstants = preload(Strings.CARD_CONSTANTS)

func get_playing_suits() -> Array[CardConstants.Suit]:
	return [CardConstants.Suit.HEARTS, CardConstants.Suit.DIAMONDS, CardConstants.Suit.CLUBS, CardConstants.Suit.SPADES]
	
func get_playing_ranks() -> Array[CardConstants.Rank]:
	return [CardConstants.Rank.TWO, CardConstants.Rank.THREE, CardConstants.Rank.FOUR, CardConstants.Rank.FIVE, CardConstants.Rank.SIX, CardConstants.Rank.SEVEN, 
	CardConstants.Rank.JACK, CardConstants.Rank.QUEEN, CardConstants.Rank.KING]

func check_brick() -> bool:
	return false

func get_shuffle_constraints() -> Dictionary:
	return {"random": true}

func get_foundation_ranks() -> Dictionary[CardConstants.Suit, CardConstants.Rank]:
	return {
		CardConstants.Suit.HEARTS: CardConstants.Rank.ACE,
		CardConstants.Suit.DIAMONDS: CardConstants.Rank.ACE,
		CardConstants.Suit.CLUBS: CardConstants.Rank.ACE,
		CardConstants.Suit.SPADES: CardConstants.Rank.ACE,
	}

func get_pile_assignment(playing_zones: Array[Pile]) -> Array[Dictionary]:
	var total_cards = get_playing_ranks().size() * get_playing_suits().size()
	var cards_per_zones: int = total_cards / playing_zones.size()
	var extra_cards = total_cards % playing_zones.size()
	var piles: Array[Dictionary] = []
	var cards_to_assign = 0
	var extra_cards_assigned = 0
	var cards_assigned = 0
	for playing_zone in playing_zones:
		if extra_cards_assigned < extra_cards:
			cards_to_assign =  cards_per_zones + 1
			extra_cards_assigned += 1
		else:
			cards_to_assign =  cards_per_zones
		cards_assigned += cards_to_assign
		piles.push_back({"pile": playing_zone, "end_index": cards_assigned})
	return piles
