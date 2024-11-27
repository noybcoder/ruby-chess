# frozen_string_literal: true

module Visualizable
  HEX_NUMBERS = (4..15).map { |num| num.to_s(16) }.freeze

  PIECE_STATS = {
    King: { rank_locations: [4], letter: 'K' },
    Queen: { rank_locations: [3], letter: 'Q' },
    Rook: { rank_locations: [0, 7], letter: 'R' },
    Bishop: { rank_locations: [2, 5], letter: 'B' },
    Knight: { rank_locations: [1, 6], letter: 'N' },
    Pawn: { rank_locations: Array(0..7) }
  }.freeze

  def piece_unicode_mapping
    PIECE_STATS.keys.each_with_index.each_with_object({}) do |(piece, idx), output|
      output[piece] = [get_unicode(HEX_NUMBERS[idx]), get_unicode(HEX_NUMBERS[idx + 6])]
    end.freeze
  end

  def get_unicode(integer)
    ["265#{integer}".to_i(16)].pack('U*')
  end
end
