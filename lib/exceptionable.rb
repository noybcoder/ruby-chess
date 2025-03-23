# frozen_string_literal: true

module Exceptionable
  def check_mate?(player)
    check_now?(player) && check_next?(player)
  end

  def check_now?(player)
    king = player.king[0]
    return true if king.current_position.nil?

    checked?(king.current_position, player).any?
  end

  def check_next?(player)
    (checked_moves(player) - opponent_next_moves(player)).empty?
  end

  def opponent_next_moves(player)
    non_pawn_next_moves(player) + pawn_next_moves(player)
  end

  def non_pawn_next_moves(player)
    king = player.king[0]
    return [] if king.checked_positions.nil?

    king.checked_positions.select { |location| checked?(location, player, true).any? }
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
    castling_type = king.instance_variable_get("@#{king.castling_type}")
    checked?(king.current_position, player).none? && checked?(castling_type, player).none?
  end

  def unblocked_castling?(king, rook)
    return false if invalid_caslting(king, rook)

    range = path_between(king.current_position[1], rook.current_position[1])
    range.all? { |idx| board.layout[king.current_position[0]][idx].nil? }
  end

  def invalid_caslting(king, rook)
    king.nil? || king.current_position.nil? || rook.current_position.nil?
  end

  def path_between(start_file, end_file)
    start_file < end_file ? Array(start_file + 1...end_file) : Array(end_file + 1...start_file)
  end

  def checked?(location, player, check = false)
    opponent(player).retrieve_pieces.select { |piece| game_paths(piece, opponent(player), location, check) }
  end

  def en_passant?(player, destination)
    !en_passant_opponent(player, destination).nil? && en_passant_opponent(player, destination).double_step[1]
  end

  def negate_en_passant(piece)
    piece.nil? || piece.current_position.nil?
  end

  def prove_en_passant(piece, player, destination)
    en_passant_target(player, destination) && pawn_blocked?([piece.double_step[0]], [destination], piece)
  end

  def en_passant_pawns(player, &block)
    opponent_pawns(player).find(&block)
  end

  def en_passant_eligible(player)
    en_passant_pawns(player) { |pawn| pawn.double_step[1] }
  end

  def en_passant_capture(player, locations)
    en_passant_pawns(player) { |pawn| !empty_path?(locations, [pawn.current_position]) }
  end

  def en_passant_opponent(player, destination)
    en_passant_capture(player, en_passant_locations(player, destination))
  end

  def en_passant_target(player, destination)
    en_passant_capture(player, en_passant_prereq(destination))
  end

  def en_passant_locations(player, destination)
    delta = [1, -1][player_turn(opponent(player))]
    [[destination[0] + delta, destination[1]]]
  end

  def en_passant_prereq(destination)
    [-1, 1].map { |delta| [destination[0], destination[1] + delta] }
  end

  def opponent_pawns(player)
    opponent(player).pawn
  end

  def opponent(player)
    (@players - [player])[0]
  end

  def promotion(stats, move_elements, player)
    promoted_piece = player.is_a?(Computer) ? player.pick_promoted_piece : parse_promotion(stats, move_elements, player)
    spare_piece = promoted_piece.find { |piece| piece.current_position.nil? }
    (spare_piece.nil? ? promotion_set(promoted_piece, player) : spare_piece)
  end

  def promotion_set(promoted_piece, player)
    count = player_turn(player)
    promoted = promoted_piece[0].class
    promoted_piece_class = player.instance_variable_get("@#{promoted.to_s.downcase}")
    promoted_piece_class << (promoted == Rook ? promoted.new(count + 1) : promoted.new)
    promoted_piece_class[-1].unicode = piece_unicode_mapping[promoted.to_s.to_sym][count]
    promoted_piece_class[-1]
  end

  def promotable?(piece)
    piece.is_a?(Pawn) && piece.promoted_position?
  end
end
