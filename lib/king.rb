# frozen_string_literal: true

require_relative 'chess'

class King < Chess
  def initialize(player_number)
    super()
    @possible_moves = [
      [1, 0], [1, 1], [0, 1], [-1, 1],
      [-1, 0], [-1, -1], [0, -1], [1, -1]
    ]
    @continuous_movement = false
    @king_castling = player_number == 1 ? [0, 2] : [7, 2]
    @queen_castling = player_number == 1 ? [0, 6] : [7, 6]
    @castling_type = nil
    @checked_positions = nil
  end

  def reset_moves
    @first_move = false if @first_move
  end
end
