extends Node3D
class_name Field

const CardConstants = preload(Strings.CARD_CONSTANTS)

@onready var deck_node: Pile = $Deck
@onready var suits_piles: Dictionary[CardConstants.Suit, Pile] = {CardConstants.Suit.HEARTS: $Foundations/HeartsPile, CardConstants.Suit.DIAMONDS: $Foundations/DiamondsPile, 
CardConstants.Suit.SPADES: $Foundations/SpadesPile, CardConstants.Suit.CLUBS: $Foundations/ClubsPile}
@onready var playing_zones: Array[Pile] = []

@export var rules: GameRuleComponent

@export var center_deck_position: Vector3

const DISTRIBUTION_DELAY := 0.1
const ANIMATION_DURATION := 0.2

func _ready():
	for node in $PlayingZones.get_children():
		playing_zones.append(node as Pile)
	center_deck_position = Vector3(0, 1, 0)

func field_cleanup():
	for child in get_tree().get_nodes_in_group("piles"):
		child.flush()
	for child in get_children():
		if child is Card:
			remove_child(child)

func place_deck_on_field(deck_array: Array[Card]):
	var i: int = 0
	for card in deck_array:
		card.current_pile = deck_node
		add_child(card)
		card.set_card_textures(CardTextureHandler.get_front_texture_path(card.rank, card.suit), CardTextureHandler.get_back_texture_path())
		deck_node.push_card(card)
		card.global_transform.origin = center_deck_position

func place_foundation_on_field(foundation_cards: Dictionary[CardConstants.Suit, Card]):
	for suit in foundation_cards:
		add_child(foundation_cards[suit])
		foundation_cards[suit].set_card_textures(CardTextureHandler.get_front_texture_path(foundation_cards[suit].rank, foundation_cards[suit].suit), CardTextureHandler.get_back_texture_path())
		suits_piles[suit].push_card(foundation_cards[suit])
		foundation_cards[suit].snap_to_position_with_animation(suits_piles[suit].snap_point, Tween.EASE_IN_OUT, Tween.TRANS_QUAD, Card.TRANS_MEDIUM)

func distribute_deck_to_piles() -> void:
	if !deck_node.cards.is_empty():
		var pile_assignment := rules.get_pile_assignment(playing_zones)
		var card_count := deck_node.cards.size()
		
		await get_tree().create_timer(0.5).timeout
		
		for i in range(0, card_count):
			var top_card: Card = deck_node.pop_card()
			
			for pile_pair in pile_assignment:
				if i < pile_pair["end_index"]:
					top_card.current_pile = pile_pair["pile"]
					break
			
			top_card.current_pile.push_card(top_card)
			
			top_card.snap_to_position_with_animation(
				top_card.current_pile.snap_point, 
				Tween.EASE_OUT, 
				Tween.TRANS_BACK, 
				ANIMATION_DURATION
			)
			top_card.woosh_sound.play()
			await get_tree().create_timer(DISTRIBUTION_DELAY).timeout

	deck_node.call_deferred("hide")
