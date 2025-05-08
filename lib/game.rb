# frozen_string_literal: true

require_relative 'human'
require_relative 'computer'
require_relative 'board'
require_relative 'visualizable'
require_relative 'parseable'
require_relative 'traceable'
require_relative 'exceptionable'
require_relative 'configurable'
require_relative 'conditionable'
require_relative 'updatable'
require_relative 'serializable'

# Main Game class that orchestrates the chess game flow, combining all modules
# and managing player interactions, game state, and serialization.
class Game
  # Include all necessary modules for game functionality
  include Parseable          # For parsing move notation
  include Visualizable       # For piece visualization
  include Traceable          # For move tracing/validation
  include Exceptionable::Castling  # Castling rules
  include Exceptionable::Promotion # Promotion rules
  include Exceptionable::EnPassant # En passant rules
  include Exceptionable::Check     # Check/checkmate detection
  include Configurable       # Game configuration
  include Conditionable      # Move condition validation
  include Updatable          # Game state updates
  include Serializable       # Save/load functionality

  attr_reader :player1, :player2, :board # Access to game components

  # Public: Initializes a new game with players and board
  # @return [Game] an instance of Game
  def initialize
    @player1 = Human.new          # Always human player
    @player2 = register_opponent  # Human or computer opponent
    @board = Board.new            # Game board
    set_up_board                  # Place pieces on board
  end

  # Public: Serializes current game state
  # @return [String] binary string representing serialized game state
  def serialize_progress
    progress = organize_variables(self)  # Gather all game variables
    serialize(progress)                  # Convert to binary format
  end

  # Public: Saves game state to file
  # @return [void]
  def save_progress
    save_data(serialize_progress) # Write to save file
  end

  # Public: Loads game state from file
  # @return [void]
  def load_progress
    deserialize(self, load_data) # Restore game state
  end

  # Public: Prompts player about save/load operation
  # @param access [String] type of operation ('save' or 'load')
  # @return [String] player choice ('y' or 'n')
  def access_progress(access = 'save')
    loop do
      puts "\nWould you like to #{access} your latest game progress? (y/n)"
      choice = player1.make_choice
      return choice if choice.match(/^y|n$/i) # Validate input
    end
  end

  # Public: Returns both players
  # @return [Array<Player>] array containing player1 and player2
  def players
    [@player1, @player2]
  end

  # Public: Registers opponent based on player choice
  # @return [Player] either a Human or Computer opponent
  def register_opponent
    if opponent_choice == 1
      Human.new # Human opponent
    else
      Computer.instance_variable_set(:@player_count, 1)
      Computer.new # Computer opponent
    end
  end

  # Public: Gets opponent choice from player
  # @return [Integer] 1 for human opponent, 2 for computer
  def opponent_choice
    loop do
      puts 'Whom would you like to play against? Enter "1" for human or "2" for computer?'
      choice = player1.make_choice
      return choice.to_i if choice.match(/^[12]$/) # Validate input
    end
  end

  # Public: Main game loop
  # @return [void]
  def play
    load_progress if access_progress('load') == 'y' # Load game if requested

    loop do
      players.each do |player|
        warning(player) # Show check warning if applicable
        break if winner?(player) # Exit if game over

        parse_notation(player) # Process player move
        break if winner?(player) # Exit if game over
      end
      break if players.any?(&method(:win_condition)) # Exit if game over

      save_progress if access_progress == 'y' # Save if requested
    end
  end

  # Public: Sets up initial board positions
  # @return [void]
  def set_up_board
    players.each do |player|
      player.retrieve_pieces.each do |piece|
        # Place each piece on the board
        board.layout[piece.current_position[0]][piece.current_position[1]] = piece
      end
    end
  end

  # Public: Gets current player index
  # @param player [Player] the player to check
  # @return [Integer] 0 for player1, 1 for player2
  def player_turn(player)
    players.find_index(player)
  end

  # Public: Processes player move notation
  # @param player [Player] the current player
  # @return [void]
  def parse_notation(player)
    player_num = player_turn(player) + 1 # Human-readable player number

    loop do
      # Get move from human or computer
      move_elements = prompt_notation(player_num, player) if player.is_a?(Human)
      king, rook = player.valid_castling if player.is_a?(Computer)
      reset_pawn(player) # Reset pawn movement flags

      next if invalid_notation(move_elements, player) # Skip if invalid move
      break if process_notation(PIECE_STATS, move_elements, player, king, rook) # Exit if valid move processed
    end
    reveal_move(player_num, player)
  end

  # Public: Prints the move made by the player
  # @param player_num [Integer] the player number (1 or 2)
  # @param player [Player] the current player
  # @return [void]
  def reveal_move(player_num, player)
    puts "\nPlayer #{player_num} just made this move => #{player.notation.join}\n\n"
  end

  # Public: Prompts human player for move notation
  # @param player_num [Integer] the player number (1 or 2)
  # @param player [Player] the current player
  # @return [Array<String>] parsed move elements or nil
  def prompt_notation(player_num, player)
    board.display_board # Show current board state
    puts "\nPlayer #{player_num}, please enter your move:"
    retrieve_notation(player) # Get and parse move input
  end

  # Public: Announces computer's turn
  # @return [nil]
  def introduce_computer
    board.display_board
    puts "\nIt is now Player 2's turn to move.\n"
    nil
  end

  # Public: Parses and validates move notation
  # @param player [Player] the current player
  # @return [Array<String>] parsed move elements or nil
  def retrieve_notation(player)
    move = player.make_choice
    # Regex pattern for standard algebraic notation:
    # 1. Piece (optional) + source (optional) + capture + destination + promotion (optional)
    # 2. Castling notation
    pattern = /^([KQRBN]?)([a-h]?[1-8]?)([x:]?)([a-h]{1}[1-8]{1})(=?[QRBN]?)$|^([O0][-[O0]]+)$/
    move.scan(pattern).flatten if move.match(pattern)
  end

  # Public: Validates move notation
  # @param move_elements [Array<String>] parsed move elements
  # @param player [Player] the current player
  # @return [Boolean] true if notation is invalid, false otherwise
  def invalid_notation(move_elements, player)
    return false unless move_elements.nil?

    return if player.is_a?(Computer)

    puts 'It not a valid chess notation. Please try again.'
    true
  end
end


# game = Game.new
# game.play
