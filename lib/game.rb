# frozen_string_literal: true

require_relative 'human'
require_relative 'computer'
require_relative 'board'
require_relative 'visualizable'
require_relative 'parseable'
require_relative 'traceable'
require_relative 'exceptionable'
require_relative 'configurable'
require_relative 'updatable'

class Game
  include Parseable
  include Visualizable
  include Traceable
  include Exceptionable
  include Configurable
  include Updatable
  attr_reader :players, :board

  def initialize(board)
    @players = register_players
    # @players = players
    @board = board
    set_up_board
  end

  def register_players
    player1 = Human.new
    player2 = register_opponent(player1)
    @players = [player1, player2]
  end

  def register_opponent(player)
    if opponent_choice(player) == 1
      Human.new
    else
      Computer.instance_variable_set(:@player_count, 1)
      Computer.new
    end
  end

  def opponent_choice(player)
    loop do
      puts 'Whom would you like to play against? Enter "1" for human or "2" for computer?'
      choice = player.make_choice
      return choice.to_i if choice.match(/^[12]$/)
    end
  end

  def play
    loop do
      players.each do |player|
        parse_notation(player)
      end
      if winner
        puts "Player #{player_turn(opponent(winner)) + 1} is the winner!"
        break
      end
    end
  end

  def winner
    players.find { |player| check_mate?(player) || player.king[0].current_position.nil? }
  end

  def set_up_board
    @players.each do |player|
      player.retrieve_pieces.each do |piece|
        board.layout[piece.current_position[0]][piece.current_position[1]] = piece
      end
    end
  end

  def endgame(player)
    check_mate?(player)
  end

  def player_turn(player)
    players.find_index(player)
  end

  def parse_notation(player)
    player_num = player_turn(player) + 1

    loop do
      move_elements = prompt_notation(player_num, player) if player.is_a?(Human)
      king, rook = player.valid_castling if player.is_a?(Computer)

      next if player.is_a?(Human) && invalid_notation(move_elements)

      if move_elements&.last || castling?(king, rook, player)
        break if castling_movement(PIECE_STATS, player, move_elements)
      elsif move_elements && move_elements.last.nil? || !castling?(king, rook, player)
        break if non_castling_movement(PIECE_STATS, player, move_elements)
      end
      next
    end
  end

  def prompt_notation(player_num, player)
    board.display_board
    puts "\nPlayer #{player_num}, please enter your move:"
    retrieve_notation(player)
  end

  def introduce_computer
    board.display_board
    puts "\nIt is now Player 2's turn to move.\n"
    nil
  end

  def retrieve_notation(player)
    move = player.make_choice
    pattern = /^([KQRBN]?)([a-h]?[1-8]?)([x:]?)([a-h]{1}[1-8]{1})(=?[QRBN]?)$|^([O0][-[O0]]+)$/
    move.scan(pattern).flatten if move.match(pattern)
  end

  def invalid_notation(move_elements)
    return unless move_elements.nil?

    puts 'It not a valid chess notation. Please try again.'
    true
  end
end

board = Board.new
# player1 = Human.new
# Computer.instance_variable_set(:@player_count, 1)
# player2 = Computer.new

game = Game.new(board)

PIECE_STATS = {
  King: { rank_locations: [4], letter: 'K' },
  Queen: { rank_locations: [3], letter: 'Q' },
  Rook: { rank_locations: [0, 7], letter: 'R' },
  Bishop: { rank_locations: [2, 5], letter: 'B' },
  Knight: { rank_locations: [1, 6], letter: 'N' },
  Pawn: { rank_locations: Array(0..7) }
}.freeze

# 0.upto(7).each do |idx|
  # unless [0, 4, 7].include?(idx)
    # board.layout[7][idx].current_position = nil
    # board.layout[7][idx] = nil
  # end

#   board.layout[7][idx].current_position = nil
#   board.layout[7][idx] = nil

#   board.layout[1][idx].current_position = nil
#   board.layout[1][idx] = board.layout[6][idx]
#   board.layout[1][idx].current_position = [1, idx]
#   board.layout[6][idx] = nil
# end

# board.layout[1][7] = board.layout[7][6]
# board.layout[7][6] = nil
# player2.knight[1].current_position = [1, 7]
# player2.knight[1].first_move = false

loop do
  game.players.each do |player|
    # game.parse_notation(player)
    # p player.notation.join
    # if game.opponent(player).king[0].current_position.nil?
    #   puts "King is defeated"
    #   break
    # end
    player_num = game.players.find_index(player) + 1

    # p "Checkmate? #{game.check_mate?(game.opponent(player))}"

    # opponent_pawn_moves = game.opponent_pawns(player).filter_map do |pawn|
    #   game.combine_paths(pawn.capture_moves, pawn, player)
    # end.flatten(2).uniq

    p game.pawn_next_moves(player)

    loop do
      move_elements = game.prompt_notation(player_num, player) if player.is_a?(Human)
      king, rook = player.is_a?(Computer) ? player.valid_castling : game.parse_castling(move_elements, player)

      next if player.is_a?(Human) && game.invalid_notation(move_elements)

      if move_elements&.last || game.castling?(king, rook, player)
        break if game.castling_movement(PIECE_STATS, player, move_elements)
      elsif move_elements && move_elements.last.nil? || !game.castling?(king, rook, player)
        break if game.non_castling_movement(PIECE_STATS, player, move_elements)
      end
      next
    end
    p player.notation.join
  end
end
