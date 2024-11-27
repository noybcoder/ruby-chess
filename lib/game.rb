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
    capture = parse_capture(move_elements)
    destination = parse_destination(move_elements)
    pieces.select do |piece|
      path?(capture, piece, destination) && (!origin || (piece.current_position.values_at(*idx) & origin).any?)
    end
  end

  def path?(capture, piece, destination)
    paths = []
    moves = capture == '' ? piece.possible_moves : piece.capture_moves

    loop do
      paths = find_path(moves, piece, paths, destination)
      break if met_path_conditions?(piece, paths, destination)
    end

    include_location?(paths, destination)
  end

  def find_path(moves, piece, paths, destination)
    moves.map.with_index do |move, idx|
      current = paths.empty? ? piece.current_position : paths[idx]
      next unless current

      new_loc = [move[0] + current[0], move[1] + current[1]]
      new_loc if clear_path?(new_loc, piece, paths, destination)
      # new_loc if valid?(new_loc)
    end
  end

  def met_path_conditions?(piece, paths, destination)
    !piece.continuous_movement || include_location?(paths, destination) || paths.none?
  end

  def clear_path?(location, piece, paths, destination)
    valid?(location) && unblocked_path?(piece, paths, destination)
  end

  def unblocked_path?(piece, paths, destination)
    piece.skip_pieces || (paths & all_locations).empty? && !include_location?(all_locations, destination)
  end

  def all_locations
    players.flat_map(&:piece_locations)
  end

  def valid?(location, low = 0, high = 7)
    location.all? { |coord| coord.between?(low, high) }
  end

  def include_location?(paths, destination)
    paths.include?(destination)
  end

  def opponent(player)
    (@players - [player])[0]
  end

  def capture_opponent(player, destination, piece)
    target = opponent(player).retrieve_pieces.find { |p| p.current_position == destination }
    target.current_position = nil if target
    board.layout[piece.current_position[0]][piece.current_position[1]] = nil
    board.layout[destination[0]][destination[1]] = piece
    piece.current_position = destination
    piece.reset_moves if piece.reset_moves
  end
end

player1 = Player.new
player2 = Player.new
board = Board.new

game = Game.new([player1, player2], board)
board.display_board
p game.parse_notation(player2)
# p player2.pawn[4]
# game.capture_opponent(player2, [4, 4], player2.pawn[4])
# p player2.pawn[4]
# game.capture_opponent(player2, [2, 4], player2.pawn[4])
# board.display_board
# p player2.pawn[4]
