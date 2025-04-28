# frozen_string_literal: true

# The Exceptionable module handles special chess rules and edge cases including:
# - Check/checkmate detection
# - Pawn promotion logic
# - En passant captures
# - Castling validation
module Exceptionable
  # Check module handles all check/checkmate related logic
  module Check
    # Public: Determines if player is in checkmate or just check based on negate flag
    # @param player [Player] The player making the move
    # @param negate [Boolean] When true checks for checkmate, false for just check
    # @return [Boolean] True if condition is met
    def check_mate?(player, negate: true)
      negate ? check_now?(player) && check_next?(player) : check_now?(player) && !check_next?(player)
    end

    # Public: Checks if player's king is currently under attack
    # @param player [Player] The player making the move
    # @return [Boolean] True if king is in check
    def check_now?(player)
      king = player.king[0]
      return true if king.current_position.nil? # King captured

      checked?(king.current_position, player).any? # Any opponent pieces attacking king
    end

    # Public: Checks if player has any legal moves to escape check
    # @param player [Player] The player making the move
    # @return [Boolean] True if no escape moves available
    def check_next?(player)
      moves = checked_moves(player)
      return false if moves.empty?
      (moves - opponent_next_moves(player)).empty?
    end

    # Public: Gets all potential opponent moves that could maintain check
    # @param player [Player] The player making the move
    # @return [Array<Array<Ineteger>>] Array of threatening positions
    def opponent_next_moves(player)
      non_pawn_next_moves(player) + pawn_next_moves(player)
    end

    # Public: Gets non-pawn pieces that could maintain check
    # @param player [Player] The player making the move
    # @return [Array<Array<Ineteger>>] Array of positions in which the non-pawn pieces can move to
    def non_pawn_next_moves(player)
      king = player.king[0]
      return [] if king.checked_positions.nil?

      king.checked_positions.select { |location| checked?(location, player, check: true).any? }
    end

    # Public: Gets pawn moves that could maintain check
    # @param player [Player] The player making the move
    # @return [Array<Array<Ineteger>>] Array of positions in which the pawns can possibly move to
    def pawn_next_moves(player)
      opponent_pawns(player).filter_map do |pawn|
        combine_paths(pawn.capture_moves, pawn, player)
      end.flatten(2).uniq
    end

    # Public: Gets all possible moves king could make to escape check
    # @param player [Player] The player making the move
    # @return [Array<Array<Ineteger>>] Array of positions in which the King is being checked
    def checked_moves(player)
      king = player.king[0]
      combine_paths(king.possible_moves, king, player).select do |path|
        valid?(path.flatten) && empty_path?(path, player.piece_locations)
      end.flatten(1)
    end

    # Public: Finds all opponent pieces attacking a given location
    # @param location [Array<Integer, Integer>] The location in which the player moves the piece to
    # @param player [Player] The player making the move
    # @param check [Boolean] Whether to perform the check
    # @return [Array<Chess>] Array of opponent pieces attacking a given location
    def checked?(location, player, check: false)
      opponent(player).retrieve_pieces.select { |piece| game_paths(piece, opponent(player), location, check: false) }
    end

    # Public: Gets opponent's pawns
    # @param player [Player] The player making the move
    # @return [Array<Pawn>] Array of opponent pawns
    def opponent_pawns(player)
      opponent(player).pawn
    end

    # Public: Gets opponent player object
    # @param player [Player] The player making the move
    # @return [Player] Opponent player object
    def opponent(player)
      (players - [player])[0]
    end
  end

  # Promotion module handles pawn promotion logic
  module Promotion
    # Public: Handles promotion piece selection
    # @param piece_stats [Hash] A hash containing chess piece statistics
    # @param move_elements [Array] Split components of the move notation
    # @param player [Player] The player making the move
    # @return [Chess] The piece that is qualified for a promotion
    def promotion(stats, move_elements, player)
      promoted_piece = if player.is_a?(Computer)
                         player.pick_promoted_piece # Computer chooses randomly
                       else
                         parse_promotion(stats, move_elements, player) # Parse human input
                       end
      # Find first available spare piece of this type
      spare_piece = promoted_piece.find { |piece| piece.current_position.nil? }
      (spare_piece.nil? ? promotion_set(promoted_piece, player) : spare_piece)
    end

    # Public: Creates new piece if no spares available
    # @param promoted_piece [Chess] The piece that is used to replace the pawn in case of a promotion
    # @param player [Player] The player making the move
    # @return [Chess] The piece that is used to replace the pawn in case of a promotion
    def promotion_set(promoted_piece, player)
      count = player_turn(player)
      promoted = promoted_piece[0].class # Find out the chess class of the promoted piece
      # Create an instance of the promoted piece
      promoted_piece_class = player.instance_variable_get("@#{promoted.to_s.downcase}")
      # Create new promoted piece and add to player's collection
      promoted_piece_class << create_promoted_piece(promoted, count)
      # Give the promoted piece its corresponding unicode character
      promoted_piece_class[-1].unicode = piece_unicode_mapping[promoted.to_s.to_sym][count]
      promoted_piece_class[-1]
    end

    # Public: Instantiates new promoted piece (special handling for Rook/Pawn)
    # @param promoted_piece [Chess] The piece that is used to replace the pawn in case of a promotion
    # @param count [Integer] Argument for instantiating an instance of Rook or Pawn
    # @return [Chess] The piece that is used to replace the pawn in case of a promotion
    def create_promoted_piece(promoted, count)
      [Rook, Pawn].include?(promoted) ? promoted.new(count + 1) : promoted.new
    end

    # Public: Checks if pawn is eligible for promotion
    # @param piece [Chess] The selected piece
    # @return [Boolean] true (false) if the piece is (not) a pawn and (or) in a spot that is (not) good for promotion
    def promotable?(piece)
      piece.is_a?(Pawn) && piece.promoted_position?
    end
  end

  # EnPassant module handles en passant capture logic
  module EnPassant
    # Public: Checks if en passant capture is possible
    # @param player [Player] The player making the move
    # @param destination [Array<Integer, Integer>] The position in which a selected piece is moved to
    # @return [Boolean] true (false) if it fulfills the en passant conditions
    def en_passant?(player, destination)
      !en_passant_opponent(player, destination).nil? && en_passant_opponent(player, destination).double_step[1]
    end

    # Public: Checks if en passant should be negated
    # @param piece [Chess] The selected piece
    # @return [Boolean] false (true) if the selected piece is (not) captured
    def negate_en_passant(piece)
      piece.nil? || piece.current_position.nil?
    end

    # Public: Validates en passant preconditions
    # @param piece [Chess] The selected piece
    # @param player [Player] The player making the move
    # @param destination [Array<Integer, Integer>] The position in which a selected piece is moved to
    # @return [Boolean] true (false) if it fulfills the en passant conditions
    def prove_en_passant(piece, player, destination)
      return false if piece.double_step.nil?

      en_passant_target(player, destination) && pawn_blocked?([piece.double_step[0]], [destination], piece)
    end

    # Public: Finds opponent pawns matching condition
    # @param player [Player] The player making the move
    # @param &block The code block in which the opponent pawn(s) satisfies(y) some conditions
    # @return [Array<Pawn>] The pawn piece(s) that satisfies(y) some conditions
    def en_passant_pawns(player, &block)
      opponent_pawns(player).find(&block)
    end

    # Public: Gets eligible en passant target pawn
    # @param player [Player] The player making the move
    # @return [Array<Pawn>] The piece(s) that is(are) en passant target pawn(s)
    def en_passant_eligible(player)
      en_passant_pawns(player) { |pawn| pawn.double_step[1] }
    end

    # Public: Finds pawn that can be captured en passant
    # @param player [Player] The player making the move
    # @param locations [Array<Array<Integer, Integer>>] All occupied board locations
    # @return [Array<Pawn>] The pawn piece(s) that can be captured en passant
    def en_passant_capture(player, locations)
      en_passant_pawns(player) { |pawn| !empty_path?(locations, [pawn.current_position]) }
    end

    # Public: Gets opponent pawn to be captured en passant
    # @param player [Player] The player making the move
    # @param destination [Array<Integer, Integer>] The position in which a selected piece is moved to
    # @return [Array<Pawn>] The opponent pawn piece(s) to be captured en passant
    def en_passant_opponent(player, destination)
      en_passant_capture(player, en_passant_locations(player, destination))
    end

    # Public: Gets target pawn for en passant
    # @param player [Player] The player making the move
    # @param destination [Array<Integer, Integer>] The position in which a selected piece is moved to
    # @return [Array<Pawn>] The target pawn piece(s) for en passant
    def en_passant_target(player, destination)
      en_passant_capture(player, en_passant_prereq(destination))
    end

    # Public: Calculates en passant capture location
    # @param player [Player] The player making the move
    # @param destination [Array<Integer, Integer>] The position in which a selected piece is moved to
    # @return [Array<Array<Integer, Integer>>] The en passant capture location
    def en_passant_locations(player, destination)
      delta = [1, -1][player_turn(opponent(player))]
      [[destination[0] + delta, destination[1]]]
    end

    # Public: Gets prerequisite positions for en passant
    # @param destination [Array<Integer, Integer>] The position in which a selected piece is moved to
    # @return [Array<Integer, Integer>] The prerequisite positions for en passant
    def en_passant_prereq(destination)
      [-1, 1].map { |delta| [destination[0], destination[1] + delta] }
    end
  end

  # Castling module handles castling validation
  module Castling
    # Public: Validates all castling conditions
    # @param king [King] The king piece
    # @param rook [Rook] The rook piece
    # @param player [Player] The player making the move
    # @return [Boolean] true (false) if the castling conditions are (not) met
    def castling?(king, rook, player)
      unblocked_castling?(king, rook) && king.first_move && rook.first_move && castling_safe?(king, player)
    end

    # Public: Checks if castling path is safe from attack
    # @param king [King] The king piece
    # @param player [Player] The player making the move
    # @return [Boolean] false (true) if the king is (not) being checked
    def castling_safe?(king, player)
      # Retrieve the castling type, i.e., king or queen castling
      castling_type = king.instance_variable_get("@#{king.castling_type}")
      checked?(king.current_position, player).none? && checked?(castling_type, player).none?
    end

    # Public: Checks if castling path is unobstructed
    # @param king [King] The king piece
    # @param rook [Rook] The rook piece
    # @return [Boolean] true (false) if the castling path is (not) clear
    def unblocked_castling?(king, rook)
      return false if invalid_caslting(king, rook) # Return false if it not eligible for castling

      # The files between the king and the rook
      range = path_between(king.current_position[1], rook.current_position[1])
      # Check if the files between the king and the rook are all clear
      range.all? { |idx| board.layout[king.current_position[0]][idx].nil? }
    end

    # Public: Basic nil checks for castling pieces
    # @param king [King] The king piece
    # @param rook [Rook] The rook piece
    # @return [Boolean] true (false) if any (both) of the king and rook is (are not) captured
    def invalid_caslting(king, rook)
      king.nil? || king.current_position.nil? || rook.current_position.nil?
    end

    # Public: Gets files between king and rook for castling
    # @param start_file [Integer] The file from the beginning of the range
    # @param end_file [Integer] The file from the end of the range
    # @return [Array<Integer>] Array of files between the king and the rook
    def path_between(start_file, end_file)
      start_file < end_file ? Array(start_file + 1...end_file) : Array(end_file + 1...start_file)
    end
  end
end
