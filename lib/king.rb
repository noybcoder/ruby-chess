# frozen_string_literal: true

require_relative 'chess'

# The King class represents the king piece in chess, inheriting from the base Chess class.
class King < Chess
  # Public: Initializes a new King piece with player-specific settings
  # @param player_number [Integer] 1 for player 1 (usually white), 2 for player 2 (usually black)
  # @return [King] an instance of King
  def initialize(player_number)
    super() # Calls parent Chess class's initialize method

    # All possible one-square movement directions for the king:
    # horizontal, vertical, and diagonal (8 possible moves)
    @possible_moves = [
      [1, 0], # South
      [1, 1],    # South-East
      [0, 1],    # East
      [-1, 1],   # North-East
      [-1, 0],   # North
      [-1, -1],  # North-West
      [0, -1],   # West
      [1, -1]    # South-West
    ]

    # Kings move one square at a time (not continuous like rooks/queens)
    @continuous_movement = false

    # Castling target positions (different for each player):
    # - Player 1 (usually white) castles on rank 0 (traditional chess rank 1)
    # - Player 2 (usually black) castles on rank 7 (traditional chess rank 8)
    @king_castling = player_number == 1 ? [0, 2] : [7, 2]    # Kingside castling target (g-file)
    @queen_castling = player_number == 1 ? [0, 6] : [7, 6]   # Queenside castling target (c-file)

    # Tracks if castling is available/being performed (nil, :king_side, or :queen_side)
    @castling_type = nil

    # Stores positions that would put this king in check (used for check validation)
    @checked_positions = nil
  end

  # Resets special move flags after the king has moved
  # (primarily used to disable castling after king's first move)
  def reset_moves
    @first_move = false if @first_move # Only update if it's still true
  end
end
