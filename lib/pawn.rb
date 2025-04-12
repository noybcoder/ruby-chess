# frozen_string_literal: true

require_relative 'chess'

class Pawn < Chess
  def initialize(player_number)
    super()
    @possible_moves = player_number == 1 ? [[1, 0]] : [[-1, 0]]
    @capture_moves = player_number == 1 ? [[1, -1], [1, 1]] : [[-1, 1], [-1, -1]]
    @promotion_rank = player_number == 1 ? 6 : 1
    @double_step = [[], false]
  end

  def reset_moves
    @first_move = false
  end

  def promoted_position?
    @current_position[0] == @promotion_rank
  end
end
