# frozen_string_literal: true

require_relative 'chess'

class Queen < Chess
  def initialize
    super
    @possible_moves = [
      [1, 0], [-1, 1], [0, 1], [1, 1],
      [-1, 0], [1, -1], [0, -1], [-1, -1]
    ]
  end
end
