# frozen_string_literal: true

require './lib/player'
require './lib/errors'

RSpec.describe Player do
  subject(:player) { described_class.new }
  before do
    described_class.player_count = 0
    allow($stdout).to receive(:write)
  end

  describe '#initialize' do
    matcher :be_shown_as do |unicode_char|
      match { |piece| piece.unicode[0] == unicode_char }
    end

    matcher :be_located_at do |location|
      match { |piece| location.include?(piece.current_position) }
    end

    context 'when the first player is created' do
      it 'increases the player count by 1 and returns 1 for the total number of players' do
        expect { described_class.new }.to change { described_class.player_count }.by(1)
        expect(described_class.player_count).to eq(1)
      end

      it 'does not raises any errors' do
        expect { described_class.new }.not_to raise_error
      end

      it 'returns a total of 16 chess pieces' do
        expect(player.retrieve_pieces.count).to eq(16)
      end

      it 'returns a total of 8 pawns that have the "♙" icon and located correctly on the board' do
        pawns = player.pawn
        expect(pawns.count).to eq(8)
        expect(pawns).to all(be_shown_as('♙'))
        expect(pawns).to all(be_located_at([[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]]))
      end

      it 'returns a total of 2 rooks that have the "♖" icon and located correctly on the board' do
        rooks = player.rook
        expect(rooks.count).to eq(2)
        expect(rooks).to all(be_shown_as('♖'))
        expect(rooks).to all(be_located_at([[0, 0], [0, 7]]))
      end

      it 'returns a total of 2 knights that have the "♘" icon and located correctly on the board' do
        knights = player.knight
        expect(knights.count).to eq(2)
        expect(knights).to all(be_shown_as('♘'))
        expect(knights).to all(be_located_at([[0, 1], [0, 6]]))
      end

      it 'returns a total of 2 bishops that have the "♗" icon and located correctly on the board' do
        bishops = player.bishop
        expect(bishops.count).to eq(2)
        expect(bishops).to all(be_shown_as('♗'))
        expect(bishops).to all(be_located_at([[0, 2], [0, 5]]))
      end

      it 'returns a total of 1 queen that have the "♕" icon and located correctly on the board' do
        queen = player.queen
        expect(queen.count).to eq(1)
        expect(queen).to all(be_shown_as('♕'))
        expect(queen).to all(be_located_at([[0, 3]]))
      end

      it 'returns a total of 1 king that have the "♔" icon and located correctly on the board' do
        king = player.instance_variable_get(:@king)
        expect(king.count).to eq(1)
        expect(king).to all(be_shown_as('♔'))
        expect(king).to all(be_located_at([[0, 4]]))
      end

      it 'returns a notation represented as an array filled with 6 nils' do
        expect(player.notation).to eq(Array.new(6))
      end
    end

    context 'when the second player is created' do
      before { described_class.player_count = 1 }
      let(:player2) { described_class.new }

      it 'increases the player count by 1 and returns 2 for total number of players' do
        expect { described_class.new }.to change { described_class.player_count }.by(1)
        expect(described_class.player_count).to eq(2)
      end

      it 'does not raises any errors' do
        expect { described_class.new }.not_to raise_error
      end

      it 'returns a total of 16 chess pieces' do
        expect(player2.retrieve_pieces.count).to eq(16)
      end

      it 'returns a total of 8 pawns that have the "♟" icon and located correctly on the board' do
        pawns = player2.pawn
        expect(pawns.count).to eq(8)
        expect(pawns).to all(be_shown_as('♟'))
        expect(pawns).to all(be_located_at([[6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]]))
      end

      it 'returns a total of 2 rooks that have the "♜" icon and located correctly on the board' do
        rooks = player2.rook
        expect(rooks.count).to eq(2)
        expect(rooks).to all(be_shown_as('♜'))
        expect(rooks).to all(be_located_at([[7, 0], [7, 7]]))
      end

      it 'returns a total of 2 knights that have the "♞" icon and located correctly on the board' do
        knights = player2.knight
        expect(knights.count).to eq(2)
        expect(knights).to all(be_shown_as('♞'))
        expect(knights).to all(be_located_at([[7, 1], [7, 6]]))
      end

      it 'returns a total of 2 bishops that have the "♝" icon and located correctly on the board' do
        bishops = player2.bishop
        expect(bishops.count).to eq(2)
        expect(bishops).to all(be_shown_as('♝'))
        expect(bishops).to all(be_located_at([[7, 2], [7, 5]]))
      end

      it 'returns a total of 1 queen that have the "♛" icon and located correctly on the board' do
        queen = player2.queen
        expect(queen.count).to eq(1)
        expect(queen).to all(be_shown_as('♛'))
        expect(queen).to all(be_located_at([[7, 3]]))
      end

      it 'returns a total of 1 king that have the "♚" icon and located correctly on the board' do
        king = player2.king
        expect(king.count).to eq(1)
        expect(king).to all(be_shown_as('♚'))
        expect(king).to all(be_located_at([[7, 4]]))
      end

      it 'returns a notation represented as an array filled with 6 nils' do
        expect(player.notation).to eq(Array.new(6))
      end
    end

    context 'when the third player is created' do
      before do
        described_class.new
        described_class.new
      end
      it 'remains 2 as the player count' do
        expect(described_class.player_count).to eq(2)
      end

      it 'raises PlayerLimitViolation error and prints the error message' do
        msg = 'Chess only allows up to 2 players.'
        expect { described_class.new }.to raise_error(CustomErrors::PlayerLimitViolation, msg)
      end
    end
  end

  describe '#piece_locations' do
    context 'when the first player calls the piece_locations at the beginning' do
      it 'returns the locations of each of the first player\'s pieces' do
        locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6],
          [1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]
        ]
        expect(player.piece_locations).to eq(locations)
      end
    end

    context 'when the first player calls the piece_locations at the beginning' do
      before { described_class.player_count = 1 }
      let(:player2) { described_class.new }

      it 'returns the locations of each of the first player\'s pieces' do
        locations = [
          [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6],
          [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(player.piece_locations).to eq(locations)
      end
    end
  end
end
