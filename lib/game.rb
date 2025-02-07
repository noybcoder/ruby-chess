# frozen_string_literal: true

require_relative 'player'
require_relative 'board'
require_relative 'visualizable'
require_relative 'parseable'
require_relative 'traceable'
require_relative 'remarkable'

class Game
  include Parseable
  include Visualizable
  include Traceable
  include Remarkable
  attr_reader :players, :board

  def initialize(players, board)
    @players = players
    @board = board
    set_up_board
  end

  def play
    loop do
      players.each do |player|
        parse_notation(player)
      end
      if winner
        puts "Player #{players.find_index(opponent(winner)) + 1} is the winner!"
        break
      end
    end
  end

  def winner
    players.find { |player| check_mate?(player) || player.king[0].current_position.nil? }
  end

  def set_up_board
    players.each do |player|
      player.retrieve_pieces.each do |piece|
        board.layout[piece.current_position[0]][piece.current_position[1]] = piece
      end
    end
  end

  def endgame(player)
    check_mate?(player)
  end

  def parse_notation(player)
    player_num = players.find_index(player) + 1

    loop do
      move_elements = prompt_notation(player_num, player)

      invalid_notation(move_elements)
      if move_elements&.last
        break if castling_movement(move_elements, player)

        next
      elsif move_elements && move_elements.last.nil?
        break if non_castling_movement(move_elements, player)

        next
      end
    end
  end

  def prompt_notation(player_num, player)
    board.display_board
    puts "\nPlayer #{player_num}, please enter your move:"
    retrieve_notation(player)
  end

  def retrieve_notation(player)
    move = player.make_move
    pattern = /^([KQRBN]?)([a-h]?[1-8]?)([x:]?)([a-h]{1}[1-8]{1})(=?[QRBN]?)$|^([O0][-[O0]]+)$/
    move.scan(pattern).flatten if move.match(pattern)
  end

  def invalid_notation(move_elements)
    puts 'It not a valid chess notation. Please try again.' if move_elements.nil?
  end

  def non_castling_movement(move_elements, player)
    pieces = parse_piece(PIECE_STATS, move_elements, player)
    origin, idx = parse_origin(move_elements)
    destination = parse_destination(move_elements)
    active_piece = pieces.select { |piece| active_piece_conditions(piece, player, origin, destination, idx) }
    make_normal_moves(active_piece, move_elements, player, destination)
  end

  def make_normal_moves(active_piece, move_elements, player, destination)
    if active_piece.length == 1
      active_piece = active_piece[0] if active_piece.length == 1
      define_piece(active_piece, move_elements, player, destination)
    elsif active_piece.length > 1
      puts "\nThere are #{active_piece.length} pieces that are eligible for the move. Please specify."
      false
    else
      puts "\nIt is not a valid move. Please try again.\n"
      false
    end
  end

  def define_piece(active_piece, move_elements, player, destination)
    if promotable?(active_piece) && move_elements[-2][-1]
      promoted_piece = promotion(active_piece, PIECE_STATS, move_elements, player)
      change_state(player, destination, active_piece, promoted_piece)
      true
    elsif !promotable?(active_piece) && move_elements[-2][-1].nil?
      change_state(player, destination, active_piece, nil)
      true
    elsif promotable?(active_piece) && move_elements[-2][-1].nil?
      puts "\nThis should be a promotion move. Please try again.\n"
      false
    else
      puts "\nThis move is not qualified for a promotion. Please try again.\n"
      false
    end
  end

  def active_piece_conditions(piece, player, origin, destination, idx)
    return false if piece.current_position.nil?

    game_paths(piece, player, destination) && (!origin || ([piece.current_position.values_at(*idx)] & [origin]).any?)
  end

  def castling_movement(move_elements, player)
    king, rook = parse_castling(move_elements, player)
    if castling?(king, rook, player)
      make_castling_moves(king, rook, player)
      true
    else
      puts "\nIt is not a valid move. Requirement(s) for castling is/are not satisfied.\n"
      false
    end
  end

  def make_castling_moves(king, rook, player)
    king.checked_positions = checked_moves(player)
    [king, rook].each do |piece|
      castling_position = piece.instance_variable_get("@#{king.castling_type}")
      change_state(player, castling_position, piece)
    end
  end

  def configure_movements(piece, destination, promoted_piece = nil)
    target = promoted_piece.nil? ? piece : promoted_piece
    board.layout[piece.current_position[0]][piece.current_position[1]] = nil
    board.layout[destination[0]][destination[1]] = target
    target.current_position = destination
    reset_piece(target)
  end

  def change_state(player, destination, piece, promoted_piece = nil)
    opp_loc = en_passant?(player, destination) ? en_passant_opponent(player, destination).current_position : destination
    board.layout[opp_loc[0]][opp_loc[1]].current_position = nil if board.layout[opp_loc[0]][opp_loc[1]]
    board.layout[opp_loc[0]][opp_loc[1]] = nil
    configure_movements(piece, destination, promoted_piece)
  end

  def reset_piece(target)
    target.reset_moves if [Pawn, King, Rook].any? { |piece| target.is_a?(piece) }
  end
end

player1 = Player.new
player2 = Player.new
board = Board.new

game = Game.new([player1, player2], board)
# board.display_board
# game.parse_notation(player2)
# board.display_board
# game.parse_notation(player2)
# board.display_board
# game.parse_notation(player1)
# board.display_board
# game.parse_notation(player2)
# board.display_board
# game.parse_notation(player2)
# board.display_board
# game.parse_notation(player2)
# board.display_board

0.upto(7) do |idx|
  board.layout[1][idx].current_position = nil
  board.layout[1][idx] = nil
end
[1, 2, 3, 5, 6].each do |idx|
  board.layout[0][idx].current_position = nil
  board.layout[0][idx] = nil
end

board.layout[1][1] = board.layout[7][1]
board.layout[7][1] = nil
player2.knight[0].current_position = [1, 1]
player2.knight[0].first_move = false

board.layout[1][0] = board.layout[6][0]
board.layout[6][0] = nil
player2.pawn[0].current_position = [1, 0]
player2.pawn[0].first_move = false

board.layout[2][2] = board.layout[6][2]
board.layout[6][2] = nil
player2.pawn[2].current_position = [2, 2]
player2.pawn[2].first_move = false

board.layout[1][3] = board.layout[6][3]
board.layout[6][3] = nil
player2.pawn[3].current_position = [1, 3]
player2.pawn[3].first_move = false

board.layout[2][4] = board.layout[7][3]
board.layout[7][3] = nil
player2.queen[0].current_position = [2, 4]
player2.queen[0].first_move = false

board.layout[1][5] = board.layout[6][5]
board.layout[6][5] = nil
player2.pawn[5].current_position = [1, 5]
player2.pawn[5].first_move = false

board.layout[2][6] = board.layout[6][6]
board.layout[6][6] = nil
player2.pawn[6].current_position = [2, 6]
player2.pawn[6].first_move = false

board.layout[1][7] = board.layout[7][6]
board.layout[7][6] = nil
player2.knight[1].current_position = [1, 7]
player2.knight[1].first_move = false

player1.king[0].checked_positions = game.checked_moves(player1)

board.display_board
game.play
board.display_board
