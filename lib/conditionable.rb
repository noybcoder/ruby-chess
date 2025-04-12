# frozen_string_literal: true

module Conditionable
  def valid_promotion?(active_piece, player, move_elements, negate: true)
    promotable = negate ? promotable?(active_piece) : !promotable?(active_piece)
    promotion_notation = (negate ? !move_elements[-2][-1].nil? : move_elements[-2][-1].nil?) if move_elements
    promotable && (player.is_a?(Computer) || promotion_notation)
  end

  def invalid_promotion(active_piece, move_elements, player)
    return if valid_promotion?(active_piece, player, move_elements)
    return if valid_promotion?(active_piece, player, move_elements, negate: false)

    if promotable?(active_piece) && move_elements[-2][-1].nil?
      puts "\nThis should be a promotion move. Please try again.\n" if player.is_a?(Human)
    elsif player.is_a?(Human)
      puts "\nThis move is not qualified for a promotion. Please try again.\n"
    end
    false
  end

  def validate_promotion(player, destination, piece_stats, active_piece, promoted_piece)
    if promoted_piece.is_a?(Pawn)
      puts "\nIt not a valid piece for promotion. Please try again.\n" if player.is_a?(Human)
      false
    else
      change_state(player, destination, piece_stats, active_piece, promoted_piece)
      active_piece.current_position = nil
      true
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

  def valid_castling?(move_elements, player, king, rook, negate: true)
    move_elements_condition = move_elements && (negate ? !move_elements.last.nil? : move_elements.last.nil?)
    castling_condition = negate ? castling?(king, rook, player) : !castling?(king, rook, player)
    move_elements_condition || castling_condition
  end

  def active_piece_conditions(piece, player, destination, origin, idx)
    return false if piece.current_position.nil?

    game_paths(piece, player, destination) && (!origin || ([piece.current_position.values_at(*idx)] & [origin]).any?)
  end

  def active_pieces(pieces, player, destination, origin = nil, idx = nil)
    pieces.select { |piece| active_piece_conditions(piece, player, destination, origin, idx) }
  end

  def warning(player)
    return unless check_mate?(player, negate: false)

    puts "Player #{player_turn(player) + 1}, you are being checked! Please make your move wisely."
  end

  def winner?(player)
    return unless win_condition(player)

    victor = king_captured?(player) ? player : opponent(player)
    puts "Player #{player_turn(victor) + 1} is the winner!"
    true
  end

  def win_condition(player)
    check_mate?(player) || king_captured?(player)
  end

  def king_captured?(player)
    opponent(player).king[0].current_position.nil?
  end
end
