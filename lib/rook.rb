# frozen_string_literal: true

require_relative 'chess'

# The Rook class represents a rook chess piece, inheriting from the base Chess class.
class Rook < Chess
  # Initializes a new Rook with player-specific castling positions
  # @param player_number [Integer] 1 for player 1 (typically white), 2 for player 2 (typically black)
  # @return [Rook] an instance of Rook
  def initialize(player_number)
    super() # Initialize base Chess class attributes

    # All possible straight movement directions for the rook:
    # The rook can move any number of squares vertically or horizontally
    @possible_moves = [
      [1, 0],   # Down (positive rank)
      [0, 1],   # Right (positive file)
      [-1, 0],  # Up (negative rank)
      [0, -1]   # Left (negative file)
    ]
    # NOTE: @continuous_movement=true (inherited from Chess) enables sliding movement

    # Castling target positions (different for each player):
    # These represent where the rook moves during castling
    @king_castling = player_number == 1 ? [0, 5] : [7, 5]   # Kingside castling position
    @queen_castling = player_number == 1 ? [0, 3] : [7, 3]  # Queenside castling position
  end

  # Disables castling eligibility after the rook's first move
  # This is called when the rook moves for the first time
  def reset_moves
    @first_move = false if @first_move # Only update if it's still true
  end
end
