# frozen_string_literal: true

require_relative 'chess'

class Knight < Chess
  def initialize
    super
    @possible_moves = [
      [2, 1], [1, 2], [-1, 2], [-2, 1],
      [-2, -1], [-1, -2], [1, -2], [2, -1]
    ]
    @skip_pieces = true
    @continuous_movement = false
  end
end
