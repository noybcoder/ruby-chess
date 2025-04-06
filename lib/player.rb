# frozen_string_literal: true

require_relative 'errors'
require_relative 'visualizable'
require_relative 'king'
require_relative 'queen'
require_relative 'rook'
require_relative 'bishop'
require_relative 'knight'
require_relative 'pawn'

class Player
  include Visualizable
  include CustomErrors
  class << self
    attr_accessor :player_count
  end

  @player_count = 0
  PLAYER_LIMIT = 2
  attr_accessor :king, :queen, :rook, :bishop, :knight, :pawn, :notation

  def initialize
    initialize_pieces
    Player.player_count += 1
    handle_game_violations(PlayerLimitViolation, Player.player_count, PLAYER_LIMIT)
    assign_chess_pieces
  end

  def initialize_pieces
    @king = []
    @queen = []
    @rook = []
    @bishop = []
    @knight = []
    @pawn = []
    @notation = Array.new(6)
  end

  def assign_chess_pieces
    PIECE_STATS.each do |key, value|
      value[:rank_locations].length.times do |col|
        count = Player.player_count - 1
        col = value[:rank_locations][col]
        create_pieces(key, count, col)
      end
    end
  end

  def create_pieces(key, count, col)
    piece = Object.const_get(key).new(*([count + 1] if %i[Pawn Rook King].include?(key)))
    row = key == :Pawn ? count * 5 + 1 : count * 7
    fill_piece_info(piece, key, count, row, col)
    instance_variable_get("@#{key.to_s.downcase}") << piece
  end

  def fill_piece_info(piece, key, count, row, col)
    piece.unicode = piece_unicode_mapping[key][count]
    piece.current_position = [row, col]
    piece.double_step[0] = [row + (row < 2 ? 2 : -2), col] if piece.double_step
  end

  def retrieve_pieces
    PIECE_STATS.flat_map { |key, _value| instance_variable_get("@#{key.downcase}") }
  end

  def piece_locations
    retrieve_pieces.map(&:current_position)
  end
end
