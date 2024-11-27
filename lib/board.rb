# frozen_string_literal: true

require_relative 'errors'
require_relative 'player'

class Board
  include CustomErrors
  attr_reader :ranks, :files
  attr_accessor :layout

  class << self
    attr_accessor :board_count
  end

  @board_count = 0
  BOARD_LIMIT = 1

  def initialize
    @ranks = Array(1..8)
    @files = Array('a'..'h')
    @layout = Array.new(8) { Array.new(8) }
    self.class.board_count += 1
    handle_game_violations(BoardLimitViolation, self.class.board_count, BOARD_LIMIT)
  end

  def display_board
    bg_colors = ["\e[48;2;222;184;135m", "\e[48;2;255;248;220m"]
    reset = "\e[0m"
    puts "   #{files.join('   ')}"
    ranks.reverse.each do |rank|
      row = layout[rank - 1].each_with_index.map do |cell, idx|
        bg_color = bg_colors[(rank + idx) % 2]
        cell_content = cell.nil? ? '    ' : " #{cell.unicode.center(2)} "
        "#{bg_color}#{cell_content}#{reset}"
      end
      puts "#{rank} #{row.join} #{rank}"
    end
    puts "   #{files.join('   ')}"
  end
end
