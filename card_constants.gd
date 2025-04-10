enum Suit {
	CLUBS, 
	SPADES, 
	DIAMONDS, 
	HEARTS
}

enum Rank {
	ACE = 1,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING
}

const suit_string_mappings = {
	Suit.CLUBS: "Clubs",
	Suit.SPADES: "Spades",
	Suit.HEARTS: "Hearts",
	Suit.DIAMONDS: "Diamonds",
}

const rank_string_mappings = {
	Rank.ACE: "A",
	Rank.JACK: "J",
	Rank.QUEEN: "Q",
	Rank.KING: "K"
}
