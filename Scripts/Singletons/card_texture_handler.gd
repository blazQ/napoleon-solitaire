extends Node

const CardConstants = preload("res://Scenes/card_constants.gd")

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
