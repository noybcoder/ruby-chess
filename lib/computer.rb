# frozen_string_literal: true

require_relative 'player'
require_relative 'configurable'
require_relative 'exceptionable'

# The Computer class represents an AI player in a chess game, inheriting from Player.
# It implements basic AI logic for making automated moves and decisions.
class Computer < Player
  include Configurable    # For game configuration settings
  include Exceptionable   # For error handling functionality

  # Accessor for storing possible move destinations the AI can choose from
  attr_accessor :available_destinations

  # Public: Initializes a new computer player with empty destination options
  # @return [Computer] an instance of Computer
  def initialize
    super() # Initialize parent Player class
    @available_destinations = nil # Will store possible move targets
  end

  # Public: Randomly selects a destination from available options
  # @return [Array] Random [rank, file] destination coordinates
  def random_destination
    available_destinations.sample # Random selection from possible moves
  end

  # Public: Retrieves all pieces that are still on the board (not captured)
  # @return [Array] Array of piece objects with current positions
  def available_pieces
    retrieve_pieces.select(&:current_position) # Filters out captured pieces
  end

  # Public: Randomly selects a piece type for pawn promotion
  # @return [Array] Array containing pieces of the promoted type
  def pick_promoted_piece
    promotion = %i[Queen Rook Bishop Knight].sample # Random promotion choice
    instance_variable_get("@#{promotion.to_s.downcase}") # Get pieces of that type
  end

  # Public: Determines valid castling options based on current piece positions
  # @return [Array] Filtered list of available castling types
  def available_castling_types
    king.product(rook).filter_map do |king, rook|
      next if king.current_position.nil? || rook.current_position.nil? # Skip if pieces are captured

      # Determine castling type based on relative positions
      king.castling_type = king.current_position[1] > rook.current_position[1] ? 'king_castling' : 'queen_castling'
    end
  end

  # Public: Selects a random valid castling move to perform
  # @return [Array] Array containing [king, rook, castling_notation]
  def valid_castling
    castling = available_castling_types.sample # Choose random castling option
    king[0].castling_type = castling # Set castling type on king

    # Return appropriate pieces and notation based on castling type
    king[0].castling_type == 'king_castling' ? [king[0], rook[0], 'O-O'] : [king[0], rook[1], 'O-O-O']
  end
end
