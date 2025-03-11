# frozen_string_literal: true

require_relative 'player'

class Human < Player
  @player_count = 0

  def make_choice
    gets.chomp
  end
end
