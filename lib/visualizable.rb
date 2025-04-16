# frozen_string_literal: true

# The Visualizable module provides functionality for chess piece visualization using Unicode characters.
module Visualizable
  # An array of hexadecimal numbers (as strings) from 4 to 15 (inclusive).
  # These numbers are used to construct Unicode code points for chess pieces.
  HEX_NUMBERS = (4..15).map { |num| num.to_s(16) }.freeze

  # A hash containing chess piece statistics including:
  # - rank_locations: The file positions (0-7) where pieces start on their rank
  # - letter: The standard algebraic notation letter for the piece (except Pawn)
  PIECE_STATS = {
    King: { rank_locations: [4], letter: 'K' }, # King starts at file e (position 4)
    Queen: { rank_locations: [3], letter: 'Q' }, # Queen starts at file d (position 3)
    Rook: { rank_locations: [0, 7], letter: 'R' }, # Rooks start at files a and h (positions 0 and 7)
    Bishop: { rank_locations: [2, 5], letter: 'B' }, # Bishops start at files c and f (positions 2 and 5)
    Knight: { rank_locations: [1, 6], letter: 'N' }, # Knights start at files b and g (positions 1 and 6)
    Pawn: { rank_locations: Array(0..7) } # Pawns are on all files (positions 0-7)
  }.freeze

  # Public: Generates a mapping of piece types to their corresponding Unicode symbols
  # for both white and black pieces.
  # @return [Hash] A frozen hash with piece symbols as values, e.g.:
  #   { King: ["♔", "♚"], Queen: ["♕", "♛"], ... }
  def piece_unicode_mapping
    # For each piece in PIECE_STATS (with index), create a hash entry where:
    # - The key is the piece name (e.g., :King)
    # - The value is an array of two Unicode characters (white and black versions)
    PIECE_STATS.keys.each_with_index.each_with_object({}) do |(piece, idx), output|
      # White piece uses HEX_NUMBERS[idx], black uses HEX_NUMBERS[idx + 6]
      output[piece] = [get_unicode(HEX_NUMBERS[idx]), get_unicode(HEX_NUMBERS[idx + 6])]
    end.freeze
  end

  # Public: Converts a hexadecimal string into a Unicode character.
  # The Unicode code points for chess pieces are in the range 0x2654-0x265F.
  # @param integer [String] A hexadecimal string (e.g., "4")
  # @return [String] The corresponding Unicode character (e.g., "♔")
  def get_unicode(integer)
    # Construct the code point by prepending "265" to the input,
    # convert to integer (base 16), then pack as Unicode character
    ["265#{integer}".to_i(16)].pack('U*')
  end
end
