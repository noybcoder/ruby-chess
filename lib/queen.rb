# frozen_string_literal: true

require_relative 'chess'

# The Queen class represents the most powerful chess piece, combining the movement
# capabilities of both a Rook and Bishop. It inherits from the base Chess class.
class Queen < Chess
  # Public: Initializes a new Queen with its combined movement capabilities.
  # @return [Queen] an instance of Queen
  def initialize
    super  # Calls the parent Chess class's initialize method

    # All possible movement directions for the queen (combination of rook and bishop moves).
    # The queen can move any number of squares in straight lines (like a rook)
    # or diagonally (like a bishop). Represented as [rank_delta, file_delta] pairs:
    @possible_moves = [
      [1, 0],    # Down (positive rank)
      [-1, 1],   # Up-right (negative rank, positive file)
      [0, 1],    # Right (positive file)
      [1, 1],    # Down-right (positive rank and file)
      [-1, 0],   # Up (negative rank)
      [1, -1],   # Down-left (positive rank, negative file)
      [0, -1],   # Left (negative file)
      [-1, -1]   # Up-left (negative rank and file)
    ]
  end
end
