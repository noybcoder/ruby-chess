# frozen_string_literal: true

# The Updatable module provides functionality for generating and updating chess move notation.
module Updatable
  # Public: Updates the move notation for non-castling moves
  # @param player [Player] The player making the move
  # @param piece_stats [Hash] Statistics about chess pieces
  # @param active_piece [Chess] The piece being moved
  # @param destination [Array] The target coordinates [rank, file]
  # @param promoted_piece [Chess, nil] The piece promoted to (if any)
  # @return [void]
  def update_non_castling_notation(player, piece_stats, active_piece, destination, promoted_piece)
    player.notation.clear # Zero out the notation
    player.notation[0] = piece_notation(piece_stats, active_piece) # Chess symbol (e.g., 'N' for knight)
    player.notation[1] = origin_notation(player, active_piece, destination) # Disambiguation if needed
    player.notation[2] = capture_notation(destination) # 'x' if capture
    location_notation(player, destination) # Destination square and en passant
    player.notation[4] = promotion_notation(piece_stats, promoted_piece) # Promotion if applicable
  end

  # Public: Sets the destination location notation and appends en passant marker if needed
  # @param player [Player] The player making the move
  # @param destination [Array] Target coordinates [rank, file]
  # @return [void]
  def location_notation(player, destination)
    player.notation[3] = board_notation(destination).join # e.g., "e5"
    player.notation[3] << en_passant_notation(player, destination).to_s # Appends ".e.p" if en passant
  end

  # Public: Updates notation specifically for castling moves
  # @param player [Player] The player castling
  # @param castling_notation [String] Either "O-O" (kingside) or "O-O-O" (queenside)
  # @return [void]
  def update_castling_notation(player, castling_notation)
    player.notation.clear
    player.notation[5] = castling_notation # Stores the castling notation separately
  end

  # Public: Returns en passant notation if the move is an en passant capture
  # @param player [Player] The player making the move
  # @param destination [Array] Target coordinates [rank, file]
  # @return [String, nil] "e.p." if en passant, otherwise nil
  def en_passant_notation(player, destination)
    ' e.p.' if en_passant?(player, destination)
  end

  # Public: Determines if the move is a capture
  # @param destination [Array] Target coordinates [rank, file]
  # @return [String, nil] "x" if capturing, otherwise nil
  def capture_notation(destination)
    'x' unless board.layout[destination[0]][destination[1]].nil?
  end

  # Public: Generates promotion notation if a pawn is being promoted
  # @param piece_stats [Hash] Statistics about chess pieces
  # @param promoted_piece [Chess, nil] The piece promoted to
  # @return [String, nil] Promotion notation (e.g., "=Q") or nil
  def promotion_notation(piece_stats, promoted_piece)
    "=#{piece_notation(piece_stats, promoted_piece)}" unless promoted_piece.nil?
  end

  # Public: Determines if origin notation is needed for disambiguation
  # @param player [Player] The player making the move
  # @param active_piece [Chess] The piece being moved
  # @param destination [Array] Target coordinates [rank, file]
  # @return [String, nil] Disambiguation notation if needed
  def origin_notation(player, active_piece, destination)
    locations = selected_locations(player, active_piece, destination)
    return nil if locations.count == 1 # No disambiguation needed if only one piece can move there

    assign_origin(locations, player, active_piece, destination)
  end

  # Public: Determines the appropriate origin disambiguation notation
  # @param locations [Array] Array of possible origin positions
  # @param player [Player] The player making the move
  # @param active_piece [Chess] The piece being moved
  # @param destination [Array] Target coordinates [rank, file]
  # @return [String] The disambiguation notation (file, rank, or both)
  def assign_origin(locations, player, active_piece, destination)
    loc_notation = location_notation(player, active_piece.current_position)
    if locations.all? { |x, _y| x == locations[0][0] } || en_passant?(player, destination)
      loc_notation[0] # Use file letter if all on same rank or en passant
    elsif locations.all? { |_x, y| y == locations[0][1] }
      loc_notation[1] # Use rank number if all on same file
    else
      loc_notation.join # Use full coordinate if needed
    end
  end

  # Public: Converts board coordinates to algebraic notation
  # @param location [Array] Coordinates [rank, file]
  # @return [Array] File and rank in algebraic notation (e.g., ["e", "5"])
  def board_notation(location, obj = board)
    [obj.files[location[1]], obj.ranks[location[0]]]
  end

  # Public: Finds all possible origin locations for pieces that could move to destination
  # @param player [Player] The player making the move
  # @param active_piece [Chess] The piece being moved
  # @param destination [Array] Target coordinates [rank, file]
  # @return [Array] Array of possible origin positions
  def selected_locations(player, active_piece, destination)
    pieces = possible_pieces(player, active_piece)
    active_pieces(pieces, player, destination).map(&:current_position)
  end

  # Public: Converts a piece object to its symbol representation
  # @param piece [Chess] The chess piece
  # @return [Symbol] The piece's class name as a symbol (e.g., :King)
  def to_symbol(piece)
    piece.to_s.to_sym
  end

  # Public: Gets the standard algebraic notation letter for a piece
  # @param piece_stats [Hash] Statistics about chess pieces
  # @param piece [Chess] The chess piece
  # @return [String] The notation letter (e.g., "N" for knight)
  def piece_notation(piece_stats, piece)
    piece_stats[to_symbol(piece.class)][:letter]
  end

  # Public: Gets all pieces of the same type as the active piece for the player
  # @param player [Player] The player making the move
  # @param active_piece [Chess] The piece being moved
  # @return [Array] Array of pieces of the same type
  def possible_pieces(player, active_piece)
    player.instance_variable_get("@#{to_symbol(active_piece.class).downcase}")
  end
end
