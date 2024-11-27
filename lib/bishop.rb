# frozen_string_literal: true

require_relative 'chess'

class Bishop < Chess
  def initialize
    super
    @possible_moves = [
      [1, 1], [-1, 1], [-1, -1], [1, -1]
    ]
  end
end
