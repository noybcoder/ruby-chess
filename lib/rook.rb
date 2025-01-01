# frozen_string_literal: true

require_relative 'chess'

class Rook < Chess
  def initialize(player_number)
    super()
    @possible_moves = [
      [1, 0], [0, 1], [-1, 0], [0, -1]
    ]
    @king_castling = player_number == 1 ? [0, 3] : [7, 3]
    @queen_castling = player_number == 1 ? [0, 5] : [7, 5]
  end

  def reset_moves
    @first_move = false if @first_move
  end
end
