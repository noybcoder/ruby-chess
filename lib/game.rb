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
require_relative 'serializable'

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
  include Serializable
  attr_reader :player1, :player2, :board

  def initialize
    @player1 = Human.new
    @player2 = register_opponent
    @board = Board.new
    set_up_board
  end

  def serialize_progress
    progress = organize_variables(self)
    serialize(progress)
  end

  def save_progress
    save_data(serialize_progress)
  end

  def load_progress
    deserialize(self, load_data)
  end

  def access_progress(access = 'save')
    loop do
      puts "Would you like to #{access} your latest game progess? (y/n)"
      choice = player1.make_choice
      return choice if choice.match(/^y|n$/i)
    end
  end

  def players
    [@player1, @player2]
  end

  def register_opponent
    if opponent_choice == 1
      Human.new
    else
      Computer.instance_variable_set(:@player_count, 1)
      Computer.new
    end
  end

  def opponent_choice
    loop do
      puts 'Whom would you like to play against? Enter "1" for human or "2" for computer?'
      choice = player1.make_choice
      return choice.to_i if choice.match(/^[12]$/)
    end
  end

  def play
    load_progress if access_progress('load') == 'y'
    loop do
      players.each do |player|
        warning(player)
        break if winner?(player)

        parse_notation(player)
      end
      break if players.any?(&method(:win_condition))

      save_progress if access_progress == 'y'
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
    players.each do |player|
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

game = Game.new
game.play
