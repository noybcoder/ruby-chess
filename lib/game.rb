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
      pattern = /^([KQRBN]?)([a-h]?[1-8]?)([x:]?)([a-h]{1}[1-8]{1})([KQRBN]?)$|^([O0][-[0O]]+)$/
      return move.scan(pattern).flatten if move.match(pattern)

      puts 'It is not a valid move. Please try again.'
    end
  end

  def parse_notation(player)
    move_elements = validate_move(player)
    pieces = parse_piece(PIECE_STATS, move_elements, player)
    origin, idx = parse_origin(move_elements)
    destination = parse_destination(move_elements)
    active_piece = pieces.find do |piece|
      path?(piece, destination) && (!origin || (piece.current_position.values_at(*idx) & origin).any?)
    end
    change_state(destination, active_piece)
  end

  def path?(piece, destination)
    piece.possible_moves.each do |move|
      path = build_path(move, piece, destination)
      return path if unblocked_path?(path[-1], destination, path[0...-1])
    end
    nil
  end

  def build_path(move, piece, destination)
    path = []
    current = piece.current_position
    loop do
      new_loc = [move[0] + current[0], move[1] + current[1]]
      path << new_loc
      break if met_path_conditions?(piece, new_loc, destination)

      current = new_loc
    end
    path
  end

  def met_path_conditions?(piece, location, destination)
    !piece.continuous_movement || !valid?(location) || destination?(location, destination)
  end

  def destination?(location, destination)
    location == destination
  end

  def unblocked_path?(location, destination, path)
    destination?(location, destination) && empty_path?(path, all_locations)
  end

  def all_locations
    players.flat_map(&:piece_locations)
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

  def change_state(destination, piece)
    board.layout[destination[0]][destination[1]] = nil if board.layout[destination[0]][destination[1]]
    board.layout[piece.current_position[0]][piece.current_position[1]] = nil
    board.layout[destination[0]][destination[1]] = piece
    piece.current_position = destination
    piece.reset_moves if piece.double_step
  end
end

player1 = Player.new
player2 = Player.new
board = Board.new

game = Game.new([player1, player2], board)
board.display_board
game.parse_notation(player2)
board.display_board
game.parse_notation(player2)
board.display_board
game.parse_notation(player2)
board.display_board
game.parse_notation(player2)
board.display_board

# paths = [
#   nil, [6, 4], [7, 4], nil, [6, 3], nil, [7, 2], [6, 2]
# ]
# piece = player2.queen[0]
# destination = [3, 7]

# paths = [
#   [5, 4], [4, 4]
# ]
# piece = player2.pawn[4]
# destination = [5, 4]

# paths = [
#   nil, nil, [6, 3], [5, 2], [5, 0], nil, nil, nil
# ]
# piece = player2.knight[0]
# destination = [5, 2]

# game.path?(player2.pawn[0], [4, 0])
