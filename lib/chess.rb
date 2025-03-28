# frozen_string_literal: true

class Chess
  attr_accessor :unicode, :current_position, :first_move, :double_step, :checked_positions, :castling_type,
                :continuous_movement
  attr_reader :possible_moves, :capture_moves, :king_castling, :queen_castling

  def initialize
    @unicode = nil
    @possible_moves = []
    @current_position = nil
    @continuous_movement = true
    @first_move = true
  end
end
