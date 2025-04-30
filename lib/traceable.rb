# frozen_string_literal: true

# The Traceable module provides functionality for tracing and validating movement paths for chess pieces.
module Traceable
  # Public: Determines if valid paths exist for a piece to reach a destination
  # @param piece [Chess] The chess piece to move
  # @param player [Player] The player making the move
  # @param destination [Array] Target coordinates [rank, file]
  # @param check [Boolean] Whether to perform the check
  # @return [Boolean] True if valid paths exist
  def game_paths(piece, player, destination, check: false)
    combine_paths(piece_moves(player, destination, piece), piece, player, destination, check: false).any?
  end

  # Public: Combines and filters all possible paths for a piece
  # @param moves [Array<Array<Integer, Integer>>] Possible movement vectors for the piece
  # @param piece [Chess] The chess piece to move
  # @param player [Player] The player making the move
  # @param destination [Array, nil] Target coordinates [rank, file] (optional)
  # @param check [Boolean] Whether to perform the check
  # @return [Array] Valid paths that meet all movement conditions
  def combine_paths(moves, piece, player, destination = nil, check: false)
    return [] if moves.nil?

    all_locs = player.piece_locations + opponent(player).piece_locations

    moves.filter_map do |move|
      path = build_path(piece.current_position, move, piece, destination)
      # Disable continuous movement for pawns if path is blocked
      piece.continuous_movement = false if destination.nil? || pawn_blocked?(path[0...-1], all_locs, piece)

      path if unblocked_path?(destination, path, all_locs, player, check: false) && double_step?(piece, destination)
    end
  end

  # Public: Checks if a path is blocked for a pawn
  # @param path [Array<Array<Integer, Integer>>] The path to check
  # @param locations [Array<Array<Integer, Integer>>] All occupied board locations
  # @param piece [Chess] The chess piece (specifically checking for pawns)
  # @return [Boolean] True if path is blocked and piece is a pawn
  def pawn_blocked?(path, locations, piece)
    !empty_path?(path, locations) && piece.is_a?(Pawn)
  end

  # Public: Validates pawn double-step move (first move only)
  # @param piece [Chess] The chess piece
  # @param destination [Array, nil] Target coordinates [rank, file]
  # @return [Boolean] True if valid double step or not a pawn
  def double_step?(piece, destination)
    return true unless destination

    !piece.is_a?(Pawn) || (destination[0] - piece.current_position[0]).abs <= 2
  end

  # Public: Determines appropriate moves based on capture context
  # @param player [Player] The player making the move
  # @param destination [Array] Target coordinates [rank, file]
  # @param piece [Chess] The chess piece
  # @return [Array] Either capture moves or regular possible moves
  def piece_moves(player, destination, piece)
    capture_moves?(player, destination, piece) ? piece.capture_moves : piece.possible_moves
  end

  # Public: Checks if the move should use capture-specific movement rules
  # @param player [Player] The player making the move
  # @param destination [Array] Target coordinates [rank, file]
  # @param piece [Chess] The chess piece
  # @return [Boolean] True if this is a capture move or en passant
  def capture_moves?(player, destination, piece)
    pawn_blocked?(opponent(player).piece_locations, [destination], piece) || en_passant?(player, destination)
  end

  # Public: Recursively builds a movement path from current position to destination
  # @param current [Array] Starting coordinates [rank, file]
  # @param move [Array] Movement vector [rank_delta, file_delta]
  # @param piece [Chess] The chess piece
  # @param destination [Array, nil] Target coordinates [rank, file]
  # @param path [Array] Accumulator for building the path
  # @return [Array] The complete movement path
  def build_path(current, move, piece, destination, path = [])
    return [] if current.nil?

    new_loc = [move[0] + current[0], move[1] + current[1]]
    path << new_loc
    return path if met_path_conditions?(piece, new_loc, destination)

    build_path(new_loc, move, piece, destination, path)
  end

  # Public: Checks if path building should terminate
  # @param piece [Chess] The chess piece
  # @param location [Array] Current coordinates being checked
  # @param destination [Array, nil] Target coordinates [rank, file]
  # @return [Boolean] True if path building should stop
  def met_path_conditions?(piece, location, destination)
    !piece.continuous_movement || !valid?(location) || location == destination
  end

  # Public: Validates if a path is unobstructed and legal
  # @param destination [Array, nil] Target coordinates [rank, file]
  # @param path [Array] The path to validate
  # @param all_locations [Array] All occupied board locations
  # @param player [Player] The player making the move
  # @param check [Boolean] Whether to perform the check
  # @return [Boolean] True if path is valid
  def unblocked_path?(destination, path, all_locations, player, check: false)
    return true unless destination

    valid_path?(destination, path, all_locations) && checking_opponent?(player, destination, check: false)
  end

  # Public: Checks if path reaches destination and is unobstructed (except destination)
  # @param destination [Array] Target coordinates [rank, file]
  # @param path [Array] The path to validate
  # @param all_locations [Array] All occupied board locations
  # @return [Boolean] True if path is valid
  def valid_path?(destination, path, all_locations)
    return false if all_locations.empty?
    (path.last == destination) && empty_path?(path[0...-1], all_locations)
  end

  # Public: Checks if move puts opponent in check (when enabled)
  # @param player [Player] The player making the move
  # @param destination [Array] Target coordinates [rank, file]
  # @param check [Boolean] Whether to perform the check
  # @return [Boolean] True if not checking or if opponent is in check
  def checking_opponent?(player, destination, check: false)
    check || empty_path?(player.piece_locations, [destination])
  end

  # Public: Validates board coordinates
  # @param location [Array] Coordinates to validate [rank, file]
  # @param low [Integer] Minimum board index (default 0)
  # @param high [Integer] Maximum board index (default 7)
  # @return [Boolean] True if coordinates are within bounds
  def valid?(location, low = 0, high = 7)
    location.all? { |coord| coord.between?(low, high) }
  end

  # Public: Checks if paths have no overlapping occupied locations
  # @param *locations [Array] Variable number of location arrays to compare
  # @return [Boolean] True if no overlapping occupied locations
  def empty_path?(*locations)
    locations.reduce(:&).empty?
  end
end
