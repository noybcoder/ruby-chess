# frozen_string_literal: true

require_relative 'player'
require_relative 'board'
require_relative 'visualizable'
require_relative 'parseable'

class Game
  include Parseable
  include Visualizable
  attr_reader :players, :board

  def initialize(players, board)
    @players = players
    @board = board
    set_up_board
  end

  def set_up_board
    players.each do |player|
      player.retrieve_pieces.each do |piece|
        board.layout[piece.current_position[0]][piece.current_position[1]] = piece
      end
    end
  end

  def validate_move(player)
    puts 'Please enter your move:'

    loop do
      move = player.make_move
      pattern = /^([KQRBN]?)([a-h]?[1-8]?)([x:]?)([a-h]{1}[1-8]{1})(=[KQRBN]?)$|^([O0][-[O0]]+)$/
      return move.scan(pattern).flatten if move.match(pattern)

      puts 'It is not a valid move. Please try again.'
    end
  end

  def parse_notation(player)
    move_elements = validate_move(player)
    if move_elements.last
      king, rook, castling = parse_castling(move_elements, player)
      king.checked_positions = checked_moves(king, player)
      if castling?(king, rook, player, castling)
        [king, rook].each do |piece|
          castling_position = piece.instance_variable_get("@#{castling}")
          configure_movements(piece, castling_position)
        end
      else
        puts 'Invalid move'
      end
    else
      pieces = parse_piece(PIECE_STATS, move_elements, player)
      origin, idx = parse_origin(move_elements)
      destination = parse_destination(move_elements)
      active_piece = pieces.find do |piece|
        game_paths(piece, player, destination) && (!origin || (piece.current_position.values_at(*idx) & origin).any?)
      end
      if active_piece.is_a?(Pawn)
        promoted_piece = parse_promotion(PIECE_STATS, move_elements, player)
        result = promoted_piece.find{ |piece| piece.current_position.nil?}

      end

      change_state(player, destination, active_piece)
    end
    promoted_piece
  end

  def checked_mate?(king, player)
    (checked_moves(king, player) - opoonent_next_moves(king, player)).empty?
  end

  def opoonent_next_moves(king, player)
    non_pawn_next_moves(king, player) + pawn_next_moves(player)
  end

  def non_pawn_next_moves(king, player)
    king.checked_positions.select{ |location| checked?(location, player).any? }
  end

  def pawn_next_moves(player)
    opponent_pawns(player).filter_map do |pawn|
      combine_paths(pawn.capture_moves, pawn, player)
    end.flatten(2).uniq
  end

  def checked_moves(king, player)
    combine_paths(king.possible_moves, king, player).select do |path|
      valid?(path) && empty_path?(path, player.piece_locations)
    end
  end

  def castling?(king, rook, player, castling)
    unblocked_castling?(king, rook) && king.first_move && rook.first_move && castling_safe?(king, player, castling)
  end

  def castling_safe?(king, player, castling)
    checked?(king.current_position, player).none? && checked?(king.instance_variable_get("@#{castling}"), player).none?
  end


  def unblocked_castling?(king, rook)
    range = path_between(king.current_position[1], rook.current_position[1])
    range.all? { |idx| board.layout[king.current_position[0]][idx].nil? }
  end

  def capture_moves?(player, destination, piece)
    !empty_path?(opponent(player).piece_locations,
                 [destination]) && piece.is_a?(Pawn) || en_passant?(player, destination)
  end

  def path_between(start_file, end_file)
    start_file < end_file ? Array(start_file + 1...end_file) : Array(end_file + 1...start_file)
  end

  def checked?(location, player)
    opponent(player).retrieve_pieces.select { |piece| game_paths(piece, opponent(player), location) }
  end

  def game_paths(piece, player, destination)
    combine_paths(piece_moves(player, destination, piece), piece, player, destination).any?
  end

  def combine_paths(moves, piece, player, destination = nil)
    moves.filter_map do |move|
      path = build_path(piece.current_position, move, piece, destination)
      path = path.flatten if piece.is_a?(King)
      path if unblocked_path?(path.last, destination, path, player)
    end
  end

  def piece_moves(player, destination, piece)
    capture_moves?(player, destination, piece) ? piece.capture_moves : piece.possible_moves
  end

  def build_path(current, move, piece, destination, path = [])
    new_loc = [move[0] + current[0], move[1] + current[1]]
    path << new_loc
    return path if met_path_conditions?(piece, new_loc, destination)
    build_path(new_loc, move, piece, destination, path)
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

  def met_path_conditions?(piece, location, destination)
    !piece.continuous_movement || !valid?(location) || location == destination
  end

  def unblocked_path?(location, destination, path, player)
    return true unless destination
    location == destination && empty_path?(path, player.piece_locations)
  end

  def valid?(location, low = 0, high = 7)
    location.all? { |coord| coord.between?(low, high) }
  end

  def empty_path?(path, destination)
    (path & destination).empty?
  end

  def opponent(player)
    (@players - [player])[0]
  end

  def configure_movements(piece, destination)
    board.layout[piece.current_position[0]][piece.current_position[1]] = nil
    board.layout[destination[0]][destination[1]] = piece
    piece.current_position = destination
    piece.reset_moves if piece.is_a?(Pawn) || piece.is_a?(King) || piece.is_a?(Rook)

  end

  def change_state(player, destination, piece)
    opp_loc = en_passant?(player, destination) ? en_passant_opponent(player, destination).current_position : destination
    board.layout[opp_loc[0]][opp_loc[1]] = nil
    configure_movements(piece, destination)
  end

end

player1 = Player.new
player2 = Player.new
board = Board.new

game = Game.new([player1, player2], board)
# board.display_board
# game.parse_notation(player1)
# board.display_board
# game.parse_notation(player1)
# board.display_board
# game.parse_notation(player2)
# board.display_board
# game.parse_notation(player1)
# board.display_board
# game.parse_notation(player1)
# board.display_board

# 0.upto(7) do |idx|
#   board.layout[1][idx].current_position = nil
#   board.layout[1][idx] = nil
# end
# [1, 2, 3, 5, 6].each do |idx|
#   board.layout[0][idx].current_position = nil
#   board.layout[0][idx] = nil
# end

# board.layout[1][1] = board.layout[7][1]
# board.layout[7][1] = nil
# player2.knight[0].current_position = [1, 1]

# board.layout[1][3] = board.layout[6][3]
# board.layout[6][3] = nil
# player2.pawn[3].current_position = [1, 3]

# board.layout[2][2] = board.layout[6][2]
# board.layout[6][2] = nil
# player2.pawn[2].current_position = [2, 2]

# board.layout[3][4] = board.layout[7][4]
# board.layout[7][4] = nil
# player2.queen[0].current_position = [3, 4]

# board.layout[1][5] = board.layout[6][5]
# board.layout[6][5] = nil
# player2.pawn[5].current_position = [1, 5]

# board.layout[2][6] = board.layout[6][6]
# board.layout[6][6] = nil
# player2.pawn[6].current_position = [2, 6]

# board.layout[1][7] = board.layout[7][6]
# board.layout[7][6] = nil
# player2.knight[1].current_position = [1, 7]

# board.layout[1][3] = board.layout[0][4]
# board.layout[0][4] = nil
# player2.king[0].current_position = [1, 3]

board.display_board
p game.parse_notation(player1)
