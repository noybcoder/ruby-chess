# frozen_string_literal: true

require_relative 'player'

# The Human class represents a human player in a chess game, inheriting from the base Player class.
class Human < Player
  # Gets the player's move choice from standard input
  # @return [String] The raw input string representing the player's move
  def make_choice
    gets.chomp  # Reads from standard input and removes trailing newline
  end
end
