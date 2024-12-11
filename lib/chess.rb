# frozen_string_literal: true

class Chess
  attr_accessor :unicode, :current_position, :captured, :first_move, :double_step
  attr_reader :possible_moves, :capture_moves, :continuous_movement

  def initialize
    @unicode = nil
    @possible_moves = []
    @current_position = nil
    @captured = false
    @continuous_movement = true
    @first_move = true
  end
end
