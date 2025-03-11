# frozen_string_literal: true

module Updatable
  def update_non_castling_notation(player, piece_stats, active_piece, destination, promoted_piece)
    player.notation.clear
    player.notation[0] = piece_notation(piece_stats, active_piece)
    player.notation[1] = origin_notation(player, active_piece, destination)
    player.notation[2] = capture_notation(player, destination)
    location_notation(player, destination)
    player.notation[4] = promotion_notation(piece_stats, promoted_piece)
  end

  def location_notation(player, destination)
    player.notation[3] = board_notation(destination).join
    player.notation[3] << en_passant_notation(player, destination).to_s
  end

  def update_castling_notation(player, castling_notation)
    player.notation.clear
    player.notation[5] = castling_notation
  end

  def en_passant_notation(player, destination)
    ' .e.p' if en_passant?(player, destination)
  end

  def capture_notation(_player, destination)
    'x' unless board.layout[destination[0]][destination[1]].nil?
  end

  def promotion_notation(piece_stats, promoted_piece)
    "=#{piece_notation(piece_stats, promoted_piece)}" unless promoted_piece.nil?
  end

  def origin_notation(player, active_piece, destination)
    locations = selected_locations(player, active_piece, destination)
    return nil if locations.count == 1

    assign_origin(locations, player, active_piece, destination)
  end

  def assign_origin(locations, player, active_piece, destination)
    loc_notation = location_notation(player, active_piece.current_position)
    if locations.all? { |x, _y| x == locations[0][0] } || en_passant?(player, destination)
      loc_notation[0]
    elsif locations.all? { |_x, y| y == locations[0][1] }
      loc_notation[1]
    else
      loc_notation.join
    end
  end

  def board_notation(location)
    [board.files[location[1]], board.ranks[location[0]]]
  end

  def selected_locations(player, active_piece, destination)
    pieces = possible_pieces(player, active_piece)
    active_pieces(pieces, player, destination).map(&:current_position)
  end

  def to_symbol(piece)
    piece.to_s.to_sym
  end

  def piece_notation(piece_stats, piece)
    piece_stats[to_symbol(piece.class)][:letter]
  end

  def possible_pieces(player, active_piece)
    player.instance_variable_get("@#{to_symbol(active_piece.class).downcase}")
  end
end
