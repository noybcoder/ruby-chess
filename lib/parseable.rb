# frozen_string_literal: true

module Parseable
  def parse_piece(piece_stats, move_elements, player)
    piece = piece_stats.find { |_k, v| v[:letter] == move_elements[0] }&.first || :Pawn
    player.instance_variable_get("@#{piece.downcase}")
  end

  def parse_origin(move_elements)
    origin = move_elements[1]
    case origin
    in /^[1-8]$/ then [[origin.to_i - 1], [0]]
    in /^[a-h]$/ then [[board.files.find_index(origin)], [1]]
    in /^[a-h]{1}[1-8]{1}$/ then [[origin[-1].to_i - 1, board.files.find_index(origin[0])], [0, 1]]
    else nil
    end
  end

  def parse_capture(move_elements)
    move_elements[2]
  end

  def parse_destination(move_elements)
    [move_elements[3][-1].to_i - 1, board.files.find_index(move_elements[3][0])]
  end

  def parse_promotion(piece_stats, move_elements, player)
    parse_piece(piece_stats, move_elements[-2][-1], player)
  end

  def parse_castling(move_elements, player)
    castling = move_elements[-1]
    case castling
    in /^(0-0|O-O)$/ then [player.king[0], player.rook[0], 'king_castling']
    in /^(0-0-0|O-O-O)$/ then [player.king[0], player.rook[1], 'queen_castling']
    else nil
    end
  end
end
