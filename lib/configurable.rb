# frozen_string_literal: true

module Configurable
  def active_pieces(pieces, player, destination, origin = nil, idx = nil)
    pieces.select { |piece| active_piece_conditions(piece, player, destination, origin, idx) }
  end

  def non_castling_movement(piece_stats, player, move_elements = nil)
    pieces = player.is_a?(Computer) ? player.available_pieces : parse_piece(piece_stats, move_elements, player)
    origin, idx = player.is_a?(Computer) ? [nil, nil] : parse_origin(move_elements)
    destination = player.is_a?(Computer) ? player.random_destination : parse_destination(move_elements)
    active_pieces = active_pieces(pieces, player, destination, origin, idx)

    make_normal_moves(active_pieces, move_elements, piece_stats, player, destination)
  end

  def make_normal_moves(active_pieces, move_elements, piece_stats, player, destination)
    if active_pieces.length == 1
      introduce_computer if player.is_a?(Computer)
      active_piece = active_pieces[0] if active_pieces.length == 1
      define_promoted_piece(active_piece, move_elements, piece_stats, player, destination)
    else
      invalid_moves(player, active_pieces)
    end
  end

  def invalid_moves(player, active_pieces)
    return if active_pieces.length == 1

    if active_pieces.length > 1
      puts "\nThere are #{active_pieces.length} pieces that can make the move. Please specify." if player.is_a?(Human)
    elsif player.is_a?(Human)
      puts "\nIt is not a valid move. Please try again.\n"
    end
    false
  end

  def define_promoted_piece(active_piece, move_elements, piece_stats, player, destination)
    if promotable?(active_piece) && (player.is_a?(Computer) || !move_elements[-2][-1].nil?)
      promoted_piece = promotion(piece_stats, move_elements, player)
      validate_promotion(player, destination, piece_stats, active_piece, promoted_piece)
    elsif !promotable?(active_piece) && (player.is_a?(Computer) || move_elements[-2][-1].nil?)
      change_state(player, destination, piece_stats, active_piece, nil)
      true
    else
      invalid_promotion(active_piece, move_elements, piece_stats, player, destination)
    end
  end

  def invalid_promotion(active_piece, move_elements, _piece_stats, player, _destination)
    return if promotable?(active_piece) && (player.is_a?(Computer) || !move_elements[-2][-1].nil?)
    return if !promotable?(active_piece) && (player.is_a?(Computer) || move_elements[-2][-1].nil?)

    if promotable?(active_piece) && move_elements[-2][-1].nil?
      puts "\nThis should be a promotion move. Please try again.\n" if player.is_a?(Human)
    elsif player.is_a?(Human)
      puts "\nThis move is not qualified for a promotion. Please try again.\n"
    end
    false
  end

  def validate_promotion(player, destination, piece_stats, active_piece, promoted_piece)
    if promoted_piece.is_a?(Pawn)
      puts "\nIt not a valid chess notation. Please try again.\n" if player.is_a?(Human)
      false
    else
      change_state(player, destination, piece_stats, active_piece, promoted_piece)
      true
    end
  end

  def active_piece_conditions(piece, player, destination, origin, idx)
    return false if piece.current_position.nil?

    game_paths(piece, player, destination) && (!origin || ([piece.current_position.values_at(*idx)] & [origin]).any?)
  end

  def castling_movement(piece_stats, player, move_elements)
    king, rook, notation = player.is_a?(Computer) ? player.valid_castling : parse_castling(move_elements, player)
    if castling?(king, rook, player)
      introduce_computer if player.is_a?(Computer)
      make_castling_moves(king, rook, player, piece_stats)
      update_castling_notation(player, notation)
      true
    else
      puts "\nIt is not a valid move. Requirement(s) for castling is/are not satisfied.\n" if player.is_a?(Human)
      false
    end
  end

  def make_castling_moves(king, rook, player, piece_stats)
    [king, rook].each do |piece|
      castling_position = piece.instance_variable_get("@#{king.castling_type}")
      change_state(player, castling_position, piece_stats, piece)
    end
  end

  def change_state(player, destination, piece_stats, piece, promoted_piece = nil)
    update_non_castling_notation(player, piece_stats, piece, destination, promoted_piece)
    exchange_positions(player, destination)
    player.king[0].checked_positions = checked_moves(player)
    opponent(player).available_destinations = available_destinations(player) if opponent(player).is_a?(Computer)

    piece.double_step[1] = true if prove_en_passant(piece, player, destination)
    en_passant_target = en_passant_eligible(player)
    standard_movements(piece, destination, promoted_piece)
    en_passant_target.double_step[1] = false unless negate_en_passant(en_passant_target)
  end

  def exchange_positions(player, destination)
    opp_loc = finalize_destination(player, destination)
    board.layout[opp_loc[0]][opp_loc[1]].current_position = nil if board.layout[opp_loc[0]][opp_loc[1]]
    board.layout[opp_loc[0]][opp_loc[1]] = nil
  end

  def finalize_destination(player, destination)
    en_passant?(player, destination) ? en_passant_opponent(player, destination).current_position : destination
  end

  def standard_movements(piece, destination, promoted_piece)
    target = promoted_piece.nil? ? piece : promoted_piece
    board.layout[piece.current_position[0]][piece.current_position[1]] = nil
    board.layout[destination[0]][destination[1]] = target
    target.current_position = destination
    reset_piece(target)
  end

  def available_destinations(player)
    board.layout.each_with_index.flat_map do |rank, rank_idx|
      rank.each_index.filter_map do |file_idx|
        cell = board.layout[rank_idx][file_idx]
        [rank_idx, file_idx] if cell.nil? || player.retrieve_pieces.include?(cell)
      end
    end
  end

  def reset_piece(target)
    target.reset_moves if [Pawn, King, Rook].any? { |piece| target.is_a?(piece) }
  end
end
