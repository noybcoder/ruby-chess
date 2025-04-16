# frozen_string_literal: true

require_relative 'chess'

# The Knight class represents a knight chess piece, inheriting from the base Chess class.
class Knight < Chess
  # Public: Initializes a new Knight with its characteristic L-shaped movement pattern.
  # @return an instance of Knight
  def initialize
    super  # Calls the parent Chess class's initialize method

    # All possible L-shaped moves for the knight (8 possible directions).
    # Knights move in an L-shape: two squares in one direction and then one square perpendicular.
    # Represented as [rank_delta, file_delta] pairs:
    @possible_moves = [
      [2, 1],   # 2 down, 1 right
      [1, 2],   # 1 down, 2 right
      [-1, 2],  # 1 up, 2 right
      [-2, 1],  # 2 up, 1 right
      [-2, -1], # 2 up, 1 left
      [-1, -2], # 1 up, 2 left
      [1, -2],  # 1 down, 2 left
      [2, -1]   # 2 down, 1 left
    ]

    # Knights cannot move continuously - they jump directly to their destination.
    # This differs from sliding pieces like rooks or bishops.
    @continuous_movement = false
  end
end
