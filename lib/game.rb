# frozen_string_literal: true

require_relative 'human'
require_relative 'computer'
require_relative 'board'
require_relative 'visualizable'
require_relative 'parseable'
require_relative 'traceable'
require_relative 'exceptionable'
require_relative 'configurable'
require_relative 'conditionable'
require_relative 'updatable'

class Game
  include Parseable
  include Visualizable
  include Traceable
  include Exceptionable::Castling
  include Exceptionable::Promotion
  include Exceptionable::EnPassant
  include Exceptionable::Check
  include Configurable
  include Conditionable
  include Updatable
  attr_reader :players, :board

  def initialize(board)
    @players = register_players
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
        warning(player)
        break if winner?(player)

        parse_notation(player)
      end
      break if players.any?(&method(:win_condition))
    end
  end

  def warning(player)
    return unless check_mate?(player, negate: false)

    puts "Player #{player_turn(player) + 1}, you are being checked! Please make your move wisely."
  end

  def winner?(player)
    return unless win_condition(player)

    puts "Player #{player_turn(opponent(player)) + 1} is the winner!"
    true
  end

  def win_condition(player)
    check_mate?(player) || player.king[0].current_position.nil?
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

      next if invalid_notation(move_elements, player)
      break if process_notation(PIECE_STATS, move_elements, player, king, rook)
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

  def invalid_notation(move_elements, player)
    return false unless move_elements.nil?

    return unless player.is_a?(Human)

    puts 'It not a valid chess notation. Please try again.'
    true
  end
end

board = Board.new
game = Game.new(board)

0.upto(7) do |idx|
  board.layout[6][idx].current_position = nil
  board.layout[6][idx] = nil

  unless [4].include?(idx)
    board.layout[7][idx].current_position = nil
    board.layout[7][idx] = nil

    board.layout[1][idx].current_position = nil
    board.layout[1][idx] = nil
  end

  unless [3, 4, 7].include?(idx)
    board.layout[0][idx].current_position = nil
    board.layout[0][idx] = nil
  end
end

# Move Player1's Queen to [6, 5] or Qf7
board.layout[4][6] = board.layout[1][4]
board.layout[4][6].current_position = [4, 6]
board.layout[1][4] = nil

board.layout[6][5] = board.layout[0][3]
board.layout[6][5].current_position = [6, 5]
board.layout[0][3] = nil

board.layout[7][6] = board.layout[7][4]
board.layout[7][6].current_position = [7, 6]
board.layout[7][4] = nil

game.players[1].king[0].checked_positions = [[6, 5], [6, 6], [6, 7], [7, 5], [7, 6], [7, 7]]
game.play
