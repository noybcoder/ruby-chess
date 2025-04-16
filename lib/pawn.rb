# frozen_string_literal: true

require_relative 'chess'

# The Pawn class represents a pawn chess piece, inheriting from the base Chess class.
class Pawn < Chess
  # Initializes a new Pawn with player-specific movement rules
  # @param player_number [Integer] 1 for player 1 (usually white), 2 for player 2 (usually black)
  # @return [Pawn] an instance of Pawn
  def initialize(player_number)
    super()  # Initialize base Chess class attributes

    # Set movement rules based on player (direction changes for white vs black):
    # - Player 1 (white) moves upward (increasing rank)
    # - Player 2 (black) moves downward (decreasing rank)
    @possible_moves = player_number == 1 ? [[1, 0]] : [[-1, 0]]  # Single forward move

    # Diagonal capture moves (different directions for each player)
    @capture_moves = player_number == 1 ? [[1, -1], [1, 1]] : [[-1, 1], [-1, -1]]

    # Rank where pawn promotes (different for each player):
    # - Player 1 (white) promotes on rank 6 (traditional chess rank 8)
    # - Player 2 (black) promotes on rank 1 (traditional chess rank 1)
    @promotion_rank = player_number == 1 ? 6 : 1

    # Tracks double-step move status:
    # - First element: stores the passed-through square during double step (for en passant)
    # - Second element: boolean flag for whether double step is available
    @double_step = [[], false]
  end

  # Disables special first move privileges after pawn has moved
  def reset_moves
    @first_move = false  # Pawns can't double-step after first move
  end

  # Checks if pawn has reached promotion rank
  # @return [Boolean] true if pawn is on its promotion rank
  def promoted_position?
    @current_position[0] == @promotion_rank  # Compare current rank with promotion rank
  end
end
