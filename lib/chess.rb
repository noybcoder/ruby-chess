# frozen_string_literal: true

class Chess
  attr_accessor :unicode, :current_position, :first_move, :double_step, :checked_positions, :castling_type
  attr_reader :possible_moves, :capture_moves, :continuous_movement, :king_castling, :queen_castling, :promotion_rank

  def initialize
    @unicode = nil
    @possible_moves = []
    @current_position = nil
    @continuous_movement = true
    @first_move = true
  end
end
