# frozen_string_literal: true

module Traceable
  def game_paths(piece, player, destination, check: false)
    combine_paths(piece_moves(player, destination, piece), piece, player, destination, check: false).any?
  end

  def combine_paths(moves, piece, player, destination = nil, check: false)
    return [] if moves.nil?

    all_locs = player.piece_locations + opponent(player).piece_locations

    moves.filter_map do |move|
      path = build_path(piece.current_position, move, piece, destination)
      piece.continuous_movement = false if destination.nil? || pawn_blocked?(path[0...-1], all_locs, piece)

      path if unblocked_path?(destination, path, all_locs, player, check: false) && double_step?(piece, destination)
    end
  end

  def pawn_blocked?(path, locations, piece)
    !empty_path?(path, locations) && piece.is_a?(Pawn)
  end

  def double_step?(piece, destination)
    return true unless destination

    !piece.is_a?(Pawn) || (destination[0] - piece.current_position[0]).abs <= 2
  end

  def piece_moves(player, destination, piece)
    capture_moves?(player, destination, piece) ? piece.capture_moves : piece.possible_moves
  end

  def capture_moves?(player, destination, piece)
    pawn_blocked?(opponent(player).piece_locations, [destination], piece) || en_passant?(player, destination)
  end

  def build_path(current, move, piece, destination, path = [])
    return [] if current.nil?

    new_loc = [move[0] + current[0], move[1] + current[1]]
    path << new_loc
    return path if met_path_conditions?(piece, new_loc, destination)

    build_path(new_loc, move, piece, destination, path)
  end

  def met_path_conditions?(piece, location, destination)
    !piece.continuous_movement || !valid?(location) || location == destination
  end

  def unblocked_path?(destination, path, all_locations, player, check: false)
    return true unless destination

    valid_path?(destination, path, all_locations) && checking_opponent?(player, destination, check: false)
  end

  def valid_path?(destination, path, all_locations)
    (path.last == destination) && empty_path?(path[0...-1], all_locations)
  end

  def checking_opponent?(player, destination, check: false)
    check || empty_path?(player.piece_locations, [destination])
  end

  def valid?(location, low = 0, high = 7)
    location.all? { |coord| coord.between?(low, high) }
  end

  def empty_path?(*locations)
    locations.reduce(:&).empty?
  end
end
