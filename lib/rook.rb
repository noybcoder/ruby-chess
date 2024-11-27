# frozen_string_literal: true

require_relative 'chess'

class Rook < Chess
  def initialize
    super
    @possible_moves = [
      [1, 0], [0, 1], [-1, 0], [0, -1]
    ]
  end
end
