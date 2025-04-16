# frozen_string_literal: true

require_relative 'errors'
require_relative 'visualizable'
require_relative 'king'
require_relative 'queen'
require_relative 'rook'
require_relative 'bishop'
require_relative 'knight'
require_relative 'pawn'

# The Player class represents a chess player, managing their pieces, notation, and game state.
class Player
  include Visualizable  # For piece display and unicode mapping
  include CustomErrors # For game violation handling

  # Class-level attributes and methods
  class << self
    attr_accessor :player_count  # Tracks number of player instances
  end

  @player_count = 0    # Initialize player counter
  PLAYER_LIMIT = 2     # Maximum allowed players (standard chess)

  # Accessors for all piece types and move notation
  attr_accessor :king, :queen, :rook, :bishop, :knight, :pawn, :notation

  # Public: Initializes a new player with all chess pieces in starting positions
  # @return [Player] an instance of Player
  def initialize
    initialize_pieces   # Set up empty piece collections
    Player.player_count += 1  # Increment player counter
    # Validate player count limit
    handle_game_violations(PlayerLimitViolation, Player.player_count, PLAYER_LIMIT)
    assign_chess_pieces # Create and position all pieces
  end

  # Public: Initializes empty arrays for all piece types and notation
  # @return [void]
  def initialize_pieces
    @king = []     # Array to store king(s)
    @queen = []    # Array to store queens
    @rook = []     # Array to store rooks
    @bishop = []   # Array to store bishops
    @knight = []   # Array to store knights
    @pawn = []     # Array to store pawns
    @notation = Array.new(6)  # Array for move notation components
  end

  # Public: Creates and positions all pieces according to standard chess setup
  # @return [void]
  def assign_chess_pieces
    PIECE_STATS.each do |key, value|
      # Create specified number of pieces for each type
      value[:rank_locations].length.times do |col|
        count = Player.player_count - 1  # Determines player number (0 or 1)
        col = value[:rank_locations][col] # Get file position from PIECE_STATS
        create_pieces(key, count, col)   # Instantiate and position piece
      end
    end
  end

  # Public: Creates individual chess pieces and positions them on the board
  # @param key [Symbol] The piece type (:King, :Queen, etc.)
  # @param count [Integer] Player index (0 or 1)
  # @param col [Integer] File (column) position
  # @return [void]
  def create_pieces(key, count, col)
    # Special initialization for Pawns, Rooks, and Kings
    piece = Object.const_get(key).new(*([count + 1] if %i[Pawn Rook King].include?(key)))

    # Calculate starting rank based on piece type and player
    row = key == :Pawn ? count * 5 + 1 : count * 7

    # Configure piece attributes and position
    fill_piece_info(piece, key, count, row, col)

    # Add piece to appropriate collection
    instance_variable_get("@#{key.to_s.downcase}") << piece
  end

  # Public: Configures a piece's visual representation and position
  # @param piece [Chess] The piece object
  # @param key [Symbol] Piece type
  # @param count [Integer] Player index
  # @param row [Integer] Rank position
  # @param col [Integer] File position
  # @return [void]
  def fill_piece_info(piece, key, count, row, col)
    # Set unicode symbol (color based on player)
    piece.unicode = piece_unicode_mapping[key][count]

    # Set current board position
    piece.current_position = [row, col]

    # Configure double-step for pawns (en passant tracking)
    piece.double_step[0] = [row + (row < 2 ? 2 : -2), col] if piece.double_step
  end

  # Public: Retrieves all pieces belonging to this player
  # @return [Array] All player's pieces
  def retrieve_pieces
    PIECE_STATS.flat_map { |key, _value| instance_variable_get("@#{key.downcase}") }
  end

  # Public: Gets current positions of all player's pieces
  # @return [Array] Array of [rank, file] positions
  def piece_locations
    retrieve_pieces.map(&:current_position)
  end
end
