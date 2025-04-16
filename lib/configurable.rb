# frozen_string_literal: true

# The Configurable module handles the core game mechanics and move processing
# for chess, including normal moves, castling, promotions, and board state management.
module Configurable
  # Public: Processes chess notation and routes to appropriate move handler
  # @return [Boolean] True if move was successfully processed
  def process_notation(piece_stats, move_elements, player, king, rook)
    if valid_castling?(move_elements, player, king, rook)
      true if castling_movement(piece_stats, player, move_elements)
    elsif valid_castling?(move_elements, player, king, rook, negate: false)
      true if non_castling_movement(piece_stats, player, move_elements)
    end
  end

  # Public: Handles standard (non-castling) chess moves
  # @return [Boolean] True if move was successfully executed
  def non_castling_movement(piece_stats, player, move_elements = nil)
    # Get relevant pieces based on player type (human or computer)
    pieces = player.is_a?(Computer) ? player.available_pieces : parse_piece(piece_stats, move_elements, player)

    # Parse origin information (for disambiguation) if human player
    origin, idx = player.is_a?(Computer) ? [nil, nil] : parse_origin(move_elements)

    # Get destination - random for computer, parsed for human
    destination = player.is_a?(Computer) ? player.random_destination : parse_destination(move_elements)

    # Find pieces that can legally move to destination
    active_pieces = active_pieces(pieces, player, destination, origin, idx)

    make_normal_moves(active_pieces, move_elements, piece_stats, player, destination)
  end

  # Public: Executes standard chess moves after validation
  # @return [Boolean] True if move was successfully made
  def make_normal_moves(active_pieces, move_elements, piece_stats, player, destination)
    if active_pieces.length == 1
      introduce_computer if player.is_a?(Computer)  # Display computer move info
      active_piece = active_pieces[0] if active_pieces.length == 1
      define_promoted_piece(active_piece, move_elements, piece_stats, player, destination)
    else
      invalid_moves(player, active_pieces)  # Handle ambiguous/invalid moves
    end
  end

  # Public: Handles promotion logic for pawn moves
  # @return [Boolean] True if promotion was successfully processed
  def define_promoted_piece(active_piece, move_elements, piece_stats, player, destination)
    if valid_promotion?(active_piece, player, move_elements)
      promoted_piece = promotion(piece_stats, move_elements, player)
      validate_promotion(player, destination, piece_stats, active_piece, promoted_piece)
    elsif valid_promotion?(active_piece, player, move_elements, negate: false)
      change_state(player, destination, piece_stats, active_piece, nil)  # Normal move
      true
    else
      invalid_promotion(active_piece, move_elements, player)  # Invalid promotion
    end
  end

  # Public: Handles castling moves
  # @return [Boolean] True if castling was successfully executed
  def castling_movement(piece_stats, player, move_elements)
    # Get castling pieces - from computer AI or human input
    king, rook, notation = player.is_a?(Computer) ? player.valid_castling : parse_castling(move_elements, player)

    if castling?(king, rook, player)
      introduce_computer if player.is_a?(Computer)  # Display computer move info
      make_castling_moves(king, rook, player, piece_stats)  # Execute castling
      update_castling_notation(player, notation)  # Update move notation
      true
    else
      # Display error for invalid castling attempt
      puts "\nIt is not a valid move. Requirement(s) for castling is/are not satisfied.\n" if player.is_a?(Human)
      false
    end
  end

  # Public: Resets pawn movement flags after first move
  # @return nil
  def reset_pawn(player)
    player.pawn.each { |pawn| pawn.continuous_movement = true if pawn.first_move == true }
  end

  # Public: Executes the actual castling movement on the board
  # @return nil
  def make_castling_moves(king, rook, player, piece_stats)
    [king, rook].each do |piece|
      # Get target position from castling type (king-side or queen-side)
      castling_position = piece.instance_variable_get("@#{king.castling_type}")
      change_state(player, castling_position, piece_stats, piece)
    end
  end

  # Public: Updates game state after a move is made
  # @return nil
  def change_state(player, destination, piece_stats, piece, promoted_piece = nil)
    update_non_castling_notation(player, piece_stats, piece, destination, promoted_piece)  # Update move notation
    exchange_positions(player, destination)  # Handle piece position changes
    player.king[0].checked_positions = checked_moves(player)  # Update check status

    # Update computer opponent's available moves if applicable
    opponent(player).available_destinations = available_destinations(player) if opponent(player).is_a?(Computer)
        standard_movements(piece, player, destination, promoted_piece)  # Complete standard move processing
  end

  # Public: Handles piece position exchanges during moves
  # @return nil
  def exchange_positions(player, destination)
    opp_loc = finalize_destination(player, destination)  # Get final destination (handles en passant)

    # Clear opponent piece if captured
    if board.layout[opp_loc[0]][opp_loc[1]]
      board.layout[opp_loc[0]][opp_loc[1]].current_position = nil
    end
    board.layout[opp_loc[0]][opp_loc[1]] = nil  # Clear board position
  end

  # Public: Determines final destination accounting for en passant
  # @return [Array] Final [rank, file] destination
  def finalize_destination(player, destination)
    en_passant?(player, destination) ? en_passant_opponent(player, destination).current_position : destination
  end

  # Public: Completes standard move processing
  # @return nil
  def standard_movements(piece, player, destination, promoted_piece)
    # Handle en passant flag for pawns
    piece.double_step[1] = true if prove_en_passant(piece, player, destination) && piece.first_move

    en_passant_target = en_passant_eligible(player)  # Get en passant target if applicable
    arrange_board(piece, destination, promoted_piece)  # Update board state

    # Reset en passant flag if not applicable
    en_passant_target.double_step[1] = false unless negate_en_passant(en_passant_target)
  end

  # Public: Updates the board with the moved piece
  # @return nil
  def arrange_board(piece, destination, promoted_piece)
    target = promoted_piece.nil? ? piece : promoted_piece  # Use promoted piece if applicable

    # Clear original position and set new position
    board.layout[piece.current_position[0]][piece.current_position[1]] = nil
    board.layout[destination[0]][destination[1]] = target
    target.current_position = destination

    reset_piece(target)  # Reset move flags if needed
  end

  # Public: Gets all available destination squares for a player
  # @return [Array] Array of [rank, file] positions
  def available_destinations(player)
    board.layout.each_with_index.flat_map do |rank, rank_idx|
      rank.each_index.filter_map do |file_idx|
        cell = board.layout[rank_idx][file_idx]
        # Include empty squares or squares with opponent pieces (captures)
        [rank_idx, file_idx] if cell.nil? || player.retrieve_pieces.include?(cell)
      end
    end
  end

  # Public: Resets move flags for pieces with special first move rules
  # @return nil
  def reset_piece(target)
    target.reset_moves if [Pawn, King, Rook].any? { |piece| target.is_a?(piece) }
  end
end
