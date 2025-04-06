# frozen_string_literal: true

require_relative 'player'

class Human < Player
  def make_choice
    gets.chomp
  end
end
