# frozen_string_literal: true

require './lib/updatable'
require './lib/conditionable'
require './lib/traceable'
require './lib/exceptionable'
require './lib/configurable'
require './lib/player'

PIECE_STATS = {
  King: { rank_locations: [4], letter: 'K' }, # King starts at file e (position 4)
  Queen: { rank_locations: [3], letter: 'Q' }, # Queen starts at file d (position 3)
  Rook: { rank_locations: [0, 7], letter: 'R' }, # Rooks start at files a and h (positions 0 and 7)
  Bishop: { rank_locations: [2, 5], letter: 'B' }, # Bishops start at files c and f (positions 2 and 5)
  Knight: { rank_locations: [1, 6], letter: 'N' }, # Knights start at files b and g (positions 1 and 6)
  Pawn: { rank_locations: Array(0..7) } # Pawns are on all files (positions 0-7)
}.freeze

RSpec.describe Updatable do
  let(:dummy_class) do
    Class.new do
      include Updatable
      include Conditionable
      include Traceable
      include Exceptionable
      include Configurable
    end.new
  end
  let(:player) { Player.new }
  let(:board) { Board.new }

  before do
    Player.player_count = 0
    Board.board_count = 0
  end

  matcher :be_chess do |piece|
    match { |p| p.is_a?(piece) }
  end

  describe '#board_notation' do
    context 'when the location [3, 4] is selected' do
      it 'returns ["e", 4]' do
        expect(dummy_class.board_notation([3, 4], board)).to eq(['e', 4])
      end
    end

    context 'when the location [7, 7] is selected' do
      it 'returns ["h", 8]' do
        expect(dummy_class.board_notation([7, 7], board)).to eq(['h', 8])
      end
    end

    context 'when the location [100, 100] is selected' do
      it 'returns [nil, nil]' do
        expect(dummy_class.board_notation([100, 100], board)).to eq([nil, nil])
      end
    end
  end

  describe '#to_symbol' do
    context 'when a pawn is selected' do
      it 'returns the pawn symbol' do
        expect(dummy_class.to_symbol(player.pawn[6].class)).to eq(:Pawn)
      end
    end

    context 'when the king is selected' do
      it 'returns the king symbol' do
        expect(dummy_class.to_symbol(player.king[0].class)).to eq(:King)
      end
    end

    context 'when a rook is selected' do
      it 'returns the rook symbol' do
        expect(dummy_class.to_symbol(player.rook[0].class)).to eq(:Rook)
      end
    end
  end

  describe '#piece_notation' do
    context 'when a pawn is selected' do
      it 'returns nil' do
        expect(dummy_class.piece_notation(PIECE_STATS, player.pawn[4])).to be_nil
      end
    end

    context 'when a king is selected' do
      it 'returns the letter K' do
        expect(dummy_class.piece_notation(PIECE_STATS, player.king[0])).to eq('K')
      end
    end

    context 'when a rook is selected' do
      it 'returns the letter R' do
        expect(dummy_class.piece_notation(PIECE_STATS, player.rook[0])).to eq('R')
      end
    end
  end

  describe '#possible_pieces' do
    context 'when a pawn is selected as the active piece' do
      it 'returns a count of 8 pieces and each piece is a pawn' do
        pawn_pieces = dummy_class.possible_pieces(player, player.pawn[1])
        expect(pawn_pieces.count).to eq(8)
        expect(pawn_pieces).to all(be_chess(Pawn))
      end
    end

    context 'when a king is selected as the active piece' do
      it 'returns a count of 1 piece and each piece is a king' do
        king_piece = dummy_class.possible_pieces(player, player.king[0])
        expect(king_piece.count).to eq(1)
        expect(king_piece).to all(be_chess(King))
      end
    end

    context 'when a rook is selected as the active piece' do
      it 'returns a count of 2 pieces and each piece is a rook' do
        rook_pieces = dummy_class.possible_pieces(player, player.rook[0])
        expect(rook_pieces.count).to eq(2)
        expect(rook_pieces).to all(be_chess(Rook))
      end
    end
  end
end
