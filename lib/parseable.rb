# frozen_string_literal: true

# The Parseable module provides functionality for parsing chess move notation
# and converting it into game objects and coordinates. It handles Standard
# Algebraic Notation (SAN) for all chess moves including special cases.
module Parseable
  # Public: Identifies a chess piece based on its notation letter
  # @param piece_stats [Hash] Piece configuration data
  # @param element [String] The notation letter (e.g., 'N' for knight)
  # @param player [Player] The player making the move
  # @return [Array] The player's pieces of the identified type (defaults to pawn)
  def identify_piece(piece_stats, element, player)
    piece = piece_stats.find { |_k, v| v[:letter] == element }&.first || :Pawn
    player.instance_variable_get("@#{piece.downcase}")
  end

  # Public: Parses the piece information from move notation
  # @param piece_stats [Hash] Piece configuration data
  # @param move_elements [Array] Split components of the move notation
  # @param player [Player] The player making the move
  # @return [Array] The player's pieces of the identified type
  def parse_piece(piece_stats, move_elements, player)
    identify_piece(piece_stats, move_elements[0], player)
  end

  # Public: Parses origin information from move notation with pattern matching
  # Handles three notation formats: rank-only, file-only, or full coordinate
  # @param move_elements [Array] Split components of the move notation
  # @return [Array, nil] Array containing position and axis info, or nil if invalid
  def parse_origin(move_elements)
    origin = move_elements[1]
    case origin
    in /^[1-8]$/ then [[origin.to_i - 1], [0]] # Rank-only (e.g., "3")
    in /^[a-h]$/ then [[board.files.find_index(origin)], [1]] # File-only (e.g., "e")
    in /^[a-h]{1}[1-8]{1}$/ then [[origin[-1].to_i - 1, board.files.find_index(origin[0])], [0, 1]] # Full coordinate (e.g., "e5")
    else nil # Invalid format
    end
  end

  # Public: Parses capture indicator from move notation
  # @param move_elements [Array] Split components of the move notation
  # @return [String, nil] The capture indicator 'x' if present
  def parse_capture(move_elements)
    move_elements[2]
  end

  # Public: Parses destination coordinates from move notation
  # @param move_elements [Array] Split components of the move notation
  # @return [Array] The destination coordinates as [rank, file]
  def parse_destination(move_elements)
    [move_elements[3][-1].to_i - 1, board.files.find_index(move_elements[3][0])]
  end

  # Public: Parses promotion information from move notation
  # @param piece_stats [Hash] Piece configuration data
  # @param move_elements [Array] Split components of the move notation
  # @param player [Player] The player making the move
  # @return [Array] The promoted-to piece type
  def parse_promotion(piece_stats, move_elements, player)
    identify_piece(piece_stats, move_elements[-2][-1], player)
  end

  # Public: Parses castling notation and prepares castling data
  # @param move_elements [Array] Split components of the move notation
  # @param player [Player] The player making the move
  # @return [Array] Array containing king, rook, and castling notation
  def parse_castling(move_elements, player)
    castling = move_elements[-1]

    case castling
    when /^(0-0|O-O)$/ # Kingside castling
      player.king[0].castling_type = 'king_castling'
      [player.king[0], player.rook[0], 'O-O']
    when /^(0-0-0|O-O-O)$/ # Queenside castling
      player.king[0].castling_type = 'queen_castling'
      [player.king[0], player.rook[1], 'O-O-O']
    end
  end
end
