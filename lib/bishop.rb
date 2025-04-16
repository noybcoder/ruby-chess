# frozen_string_literal: true

require_relative 'chess'

# The Bishop class represents a bishop chess piece, inheriting from the base Chess class.
class Bishop < Chess
  # Public: Initializes a new Bishop with its characteristic diagonal movement pattern.
  # @return [Bishop] an instance of Bishop
  def initialize
    super  # Calls the parent Chess class's initialize method

    # All possible diagonal movement directions for the bishop.
    # Bishops can move any number of squares diagonally (handled by continuous_movement=true from parent).
    # The moves are represented as [rank_delta, file_delta] pairs:
    @possible_moves = [
      [1, 1],    # Down-right diagonal (positive rank, positive file)
      [-1, 1],   # Up-right diagonal (negative rank, positive file)
      [-1, -1],  # Up-left diagonal (negative rank, negative file)
      [1, -1]    # Down-left diagonal (positive rank, negative file)
    ]
    # Note: The @continuous_movement=true (inherited from Chess parent class)
    # allows the bishop to slide multiple squares in these directions.
  end
end
