# frozen_string_literal: true

require_relative 'player'
require_relative 'configurable'
require_relative 'exceptionable'

class Computer < Player
  include Configurable
  include Exceptionable

  @player_count = 0
  attr_accessor :available_destinations

  def initialize
    super()
    @available_destinations = nil
  end

  def random_destination
    available_destinations.sample
  end

  def available_pieces
    retrieve_pieces.select(&:current_position)
  end

  def pick_promoted_piece
    promotion = %i[Queen Rook Bishop Knight].sample
    instance_variable_get("@#{promotion.to_s.downcase}")
  end

  def available_castling_types
    king.product(rook).filter_map do |king, rook|
      next if king.current_position.nil? || rook.current_position.nil?

      king.castling_type = king.current_position[1] > rook.current_position[1] ? 'king_castling' : 'queen_castling'
    end
  end

  def valid_castling
    castling = available_castling_types.sample
    king[0].castling_type = castling
    king[0].castling_type == 'king_castling' ? [king[0], rook[0], 'O-O'] : [king[0], rook[1], 'O-O-O']
  end
end
