# frozen_string_literal: true

# The Chess class serves as a base class for chess pieces
class Chess
  # Attribute accessors for mutable piece properties
  attr_accessor :unicode,           # Unicode symbol for the piece (different for white/black)
                :current_position,  # Current [rank, file] coordinates on the board
                :first_move,        # Tracks if piece hasn't moved yet (for castling/en passant)
                :double_step,       # Flag for pawn's double-step first move
                :checked_positions, # Tracks positions that put king in check
                :castling_type,     # Type of castling (kingside/queenside)
                :continuous_movement # Whether piece can move multiple squares (like rook/queen/bishop)

  # Attribute readers for immutable movement patterns
  attr_reader :possible_moves,  # Array of regular movement vectors [[rank_delta, file_delta]]
              :capture_moves,   # Array of capture-specific movement vectors (differs for pawns)
              :king_castling,  # Castling move vector for king-side
              :queen_castling  # Castling move vector for queen-side

  # Public: Initializes a new chess piece with default values
  # @return [Chess] an instance of Chess
  def initialize
    @unicode = nil             # Must be set by subclass
    @possible_moves = []       # Must be populated by subclass
    @current_position = nil    # Set when piece is placed on board
    @continuous_movement = true # Default true (for rook/bishop/queen), false for others
    @first_move = true         # Tracks if piece hasn't moved yet
    # Note: capture_moves, king_castling, and queen_castling are typically
    # initialized in subclasses that need them (like Pawn and King)
  end
end
