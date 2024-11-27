# frozen_string_literal: true

require_relative 'chess'

class King < Chess
  def initialize
    super
    @possible_moves = [
      [1, 0], [1, 1], [0, 1], [-1, 1],
      [-1, 0], [-1, -1], [0, -1], [1, -1]
    ]
    @checked = false
    @continuous_movement = false
  end
end
