# frozen_string_literal: true

module Remarkable
  def check_mate?(player)
    return false if checked_moves(player).empty?
    (checked_moves(player) - opponent_next_moves(player)).empty?
  end

  def opponent_next_moves(player)
    non_pawn_next_moves(player) + pawn_next_moves(player)
  end

  def non_pawn_next_moves(player)
    king = player.king[0]
    return [] if king.checked_positions.nil?

    king.checked_positions.select { |location| checked?(location, player).any? }
  end

  def pawn_next_moves(player)
    opponent_pawns(player).filter_map do |pawn|
      combine_paths(pawn.capture_moves, pawn, player)
    end.flatten(2).uniq
  end

  def checked_moves(player)
    king = player.king[0]
    combine_paths(king.possible_moves, king, player).select do |path|
      valid?(path.flatten) && empty_path?(path, player.piece_locations)
    end.flatten(1)
  end

  def castling?(king, rook, player)
    unblocked_castling?(king, rook) && king.first_move && rook.first_move && castling_safe?(king, player)
  end

  def castling_safe?(king, player)
    checked?(king.current_position,
             player).none? && checked?(king.instance_variable_get("@#{king.castling_type}"), player).none?
  end

  def unblocked_castling?(king, rook)
    return false if king.nil?

    range = path_between(king.current_position[1], rook.current_position[1])
    range.all? { |idx| board.layout[king.current_position[0]][idx].nil? }
  end

  def path_between(start_file, end_file)
    start_file < end_file ? Array(start_file + 1...end_file) : Array(end_file + 1...start_file)
  end

  def checked?(location, player)
    opponent(player).retrieve_pieces.select { |piece| game_paths(piece, opponent(player), location) }
  end

  def en_passant?(player, destination)
    !en_passant_opponent(player, destination).nil? && en_passant_opponent(player, destination).double_step[1]
  end

  def en_passant_opponent(player, destination)
    opponent_pawns(player).find { |pawn| !empty_path?(en_passant_locations(destination), [pawn.current_position]) }
  end

  def en_passant_locations(destination)
    [1, -1].map { |delta| [destination[0] + delta, destination[1]] }
  end

  def opponent_pawns(player)
    opponent(player).retrieve_pieces.select { |piece| piece.is_a?(Pawn) }
  end

  def opponent(player)
    (@players - [player])[0]
  end

  def promotion(_piece, stats, move_elements, player)
    promoted_piece = parse_promotion(stats, move_elements, player)
    spare_piece = promoted_piece.find { |piece| piece.current_position.nil? }
    promotion_set(spare_piece, promoted_piece, player)
  end

  def promotion_set(spare_piece, promoted_piece, player)
    return unless spare_piece.nil?

    count = players.find_index(player)
    promoted = promoted_piece[0].class
    promotion_set = player.instance_variable_get("@#{promoted.to_s.downcase}")
    promotion_set << promoted.new(count + 1) if promoted == Rook
    promotion_set[-1].unicode = piece_unicode_mapping[promoted.to_s.to_sym][count]
    promotion_set[-1]
  end

  def promotable?(piece)
    piece.is_a?(Pawn) && piece.promoted_position?
  end
end
