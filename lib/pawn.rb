# frozen_string_literal: true

require_relative 'chess'

class Pawn < Chess
  def initialize(player_number)
    super()
    @possible_moves = player_number == 1 ? [[1, 0], [2, 0]] : [[-1, 0], [-2, 0]]
    @capture_moves = player_number == 1 ? [[1, -1], [1, 1]] : [[-1, 1], [-1, -1]]
    @promotion_rank = player_number == 1 ? 7 : 1
    @double_step = [[], false]
    @continuous_movement = false
  end

  def reset_moves
    if @first_move
      @possible_moves.pop
      @first_move = false
    end
    @double_step[1] = @current_position == @double_step[0]
  end

  def promoted_position?
    @current_position[0] == @promotion_rank
  end
end
