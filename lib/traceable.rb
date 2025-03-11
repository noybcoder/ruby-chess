# frozen_string_literal: true

module Traceable
  def game_paths(piece, player, destination)
    combine_paths(piece_moves(player, destination, piece), piece, player, destination).any?
  end

  def combine_paths(moves, piece, player, destination = nil)
    return [] if moves.nil?

    moves.filter_map do |move|
      path = build_path(piece.current_position, move, piece, destination)
      path if unblocked_path?(path.last, destination, path, player) && double_step_limited?(piece, destination)
    end
  end

  def double_step_limited?(piece, destination)
    !piece.is_a?(Pawn) || (destination[0] - piece.current_position[0]).abs <= 2
  end

  def piece_moves(player, destination, piece)
    capture_moves?(player, destination, piece) ? piece.capture_moves : piece.possible_moves
  end

  def capture_moves?(player, destination, piece)
    !empty_path?(opponent(player).piece_locations,
                 [destination]) && piece.is_a?(Pawn) || en_passant?(player, destination)
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

  def unblocked_path?(location, destination, path, player)
    return true unless destination

    all_locations = player.piece_locations + opponent(player).piece_locations
    (location == destination) && empty_path?(path[0...-1],
                                             all_locations) && empty_path?(player.piece_locations, [destination])
  end

  def valid?(location, low = 0, high = 7)
    location.all? { |coord| coord.between?(low, high) }
  end

  def empty_path?(*locations)
    locations.reduce(:&).empty?
  end
end
