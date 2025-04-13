extends Node3D

const CardScene = preload("res://Scenes/card.tscn")
const CardConstants = preload("res://Scripts/card_constants.gd")

var deck : Array
var deck_node

var piles_filled : int = 0

signal card_instanced(card)
signal game_over()

# ------------------------------- Scene Instancing
func _ready():
	deck_node = $Zones/Deck
	for pile in get_tree().get_nodes_in_group("special_piles"):
		pile.pile_filled.connect(_on_pile_filled)
	instance_deck()
	deck.shuffle()
	place_deck()
	place_aces()

## Instancing the deck and placing it in the deck pile
func instance_deck():
	for suit in [CardConstants.Suit.CLUBS, CardConstants.Suit.DIAMONDS, CardConstants.Suit.HEARTS, CardConstants.Suit.SPADES]:
		for rank in [CardConstants.Rank.TWO, CardConstants.Rank.THREE, CardConstants.Rank.FOUR, CardConstants.Rank.FIVE, 
		CardConstants.Rank.SIX, CardConstants.Rank.SEVEN, CardConstants.Rank.JACK, CardConstants.Rank.QUEEN, CardConstants.Rank.KING]:
			var card = create_and_set_card(rank, suit, deck_node)
			add_child(card)
			deck.push_front(card)

## Creating and setting properties for a dynamically instanced card
func create_and_set_card(rank: CardConstants.Rank, suit: CardConstants.Suit, initial_pile):
	var card = CardScene.instantiate()
	card.add_to_group("cards")
	emit_signal("card_instanced", card)
	card.set_card_values(rank, suit)
	card.set_card_texture_paths(get_front_texture_path(rank, suit), get_back_texture_path())
	card.set_card_textures()
	card.card_popped.connect(_on_card_popped)
	card.card_pushed.connect(_on_card_pushed)
	card.current_pile = initial_pile
	return card 

## Helper function to place cards in the deck
func place_aces():
	for suit in [CardConstants.Suit.CLUBS, CardConstants.Suit.DIAMONDS, CardConstants.Suit.HEARTS, CardConstants.Suit.SPADES]:
			var card = create_and_set_card(CardConstants.Rank.ACE, suit, get_suit_pile(suit))
			add_child(card)
			card.push_to_current_pile()
			card.is_finalized = true
			card.get_node("CollisionShape3D").disabled = true

## Helper function to get the drop zone associated with every suit
func get_suit_pile(suit: CardConstants.Suit):
	if suit == CardConstants.Suit.CLUBS:
		return $Zones/ClubsPile
	elif suit == CardConstants.Suit.SPADES:
		return $Zones/SpadesPile
	elif suit == CardConstants.Suit.DIAMONDS:
		return $Zones/DiamondsPile
	elif suit == CardConstants.Suit.HEARTS:
		return $Zones/HeartsPile

## Helper function to place cards in the deck
func place_deck():
	for card in deck:
		card.push_to_current_pile()
		

func delete_deck_node():
	deck_node.call_deferred("queue_free")

func check_brick():
	pass

# --------------------------------  Resource Handling

# Helper function to get the resource string associated with card textures
func get_front_texture_path(rank, suit):
	var texture_path = "res://Assets/Cards/card" + CardConstants.suit_string_mappings[suit]
	if rank in [1, 11, 12, 13]:
		texture_path += CardConstants.rank_string_mappings[rank]
	else: 
		texture_path += str(rank)
	return texture_path + ".png"

# Helper function to get the resource string associated with the card's back texture
func get_back_texture_path():
	return "res://Assets/Cards/cardBack_red2.png"


# ---------------------------------  Collision Handling

# Handling every time a card is pushed in a drop zone by updating its collision shape so it's no longer selectable
# If it's not the top of its respective drop zone
func _on_card_pushed(_pushed_card: Area3D, _pile: Area3D):
	for card in get_tree().get_nodes_in_group("cards"):
		if !card.is_pile_top:
			card.get_node("CollisionShape3D").disabled = true
		elif card.is_pile_top and !card.is_finalized:
			card.get_node("CollisionShape3D").disabled = false
	check_brick()

# Handling every time a card is popped from a drop zone by updating its collision shape so it's no longer selectable.
# Popping a card from a drop zone implicitly means moving it to the player's hand.
# Might change if the game rules require it.
func _on_card_popped(popped_card: Area3D, _pile: Area3D):
	for card in get_tree().get_nodes_in_group("cards"):
		if card != popped_card:
			card.get_node("CollisionShape3D").disabled = true

func _on_game_start_timeout() -> void:
	var card_index: int = 0
	var piles = [
		{"limit": 5,  "zone": $Zones/A1},
		{"limit": 10, "zone": $Zones/A2},
		{"limit": 15, "zone": $Zones/B1},
		{"limit": 20, "zone": $Zones/B2},
		{"limit": 24, "zone": $Zones/A3},
		{"limit": 28, "zone": $Zones/A4},
		{"limit": 32, "zone": $Zones/B3},
		{"limit": 36, "zone": $Zones/B4},
	]

	for i in range(deck.size()-1, -1, -1):
		deck[i].pop_from_current_pile()
		for dz in piles:
			if card_index < dz.limit:
				deck[i].current_pile = dz.zone
				deck[i].last_pile = dz.zone
				break
		deck[i].push_to_current_pile()
		card_index += 1
	$Shuffle.play()
	$InputBlocker.call_deferred("queue_free")
	delete_deck_node()
	

func _on_pile_filled():
	piles_filled += 1
	if piles_filled == 4:
		emit_signal("game_over")

func _on_game_over():
	pass
