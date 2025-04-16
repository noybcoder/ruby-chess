# frozen_string_literal: true

require_relative 'errors'
require_relative 'player'

# The Board class represents a chess board.
class Board
  include CustomErrors  # Includes custom error handling functionality
  attr_reader :ranks, :files  # Board coordinates (1-8 and a-h)
  attr_accessor :layout       # 2D array representing piece positions

  # Class-level attributes and methods
  class << self
    attr_accessor :board_count  # Tracks number of board instances
    attr_reader :background_colors, :color_offset  # Display colors
  end

  # Class variables initialization
  @board_count = 0       # Counter for board instances
  BOARD_LIMIT = 1        # Maximum allowed board instances

  # Public: Initializes a new chess board with default configuration
  # @return [Board] an instance of Board
  def initialize
    # ANSI color codes for chess board squares (dark and light)
    @background_colors = ["\e[48;2;222;184;135m", "\e[48;2;255;248;220m"]
    @color_offset = "\e[0m"  # ANSI reset code

    # Board coordinate systems
    @ranks = Array(1..8)     # Vertical ranks (1-8)
    @files = Array('a'..'h') # Horizontal files (a-h)

    # 8x8 grid to store pieces (nil represents empty square)
    @layout = Array.new(8) { Array.new(8) }

    # Track and validate board instances
    self.class.board_count += 1
    handle_game_violations(BoardLimitViolation, self.class.board_count, BOARD_LIMIT)
  end

  # Public: Displays the current board state with coordinates and pieces
  # @return [void]
  def display_board
    # Print top files (column letters)
    puts "   #{files.join('   ')}"

    # Print each rank (row) from top to bottom (8 to 1)
    ranks.reverse.each do |rank|
      row = board_content(rank)  # Get formatted row content
      puts "#{rank} #{row.join} #{rank}"  # Print row with rank numbers
    end

    # Print bottom files (column letters)
    puts "   #{files.join('   ')}"
  end

  # Generates formatted content for a single rank (row)
  # @param rank [Integer] The rank number (1-8)
  # @return [Array] Formatted cells for the rank
  def board_content(rank)
    layout[rank - 1].each_with_index.map do |cell, idx|
      # Alternate background colors for checkered pattern
      bg_color = @background_colors[(rank + idx) % 2]

      # Format cell content (empty or with piece)
      cell_content = cell.nil? ? '    ' : " #{cell.unicode.center(2)} "

      # Combine color and content with reset
      "#{bg_color}#{cell_content}#{@color_offset}"
    end
  end
end
