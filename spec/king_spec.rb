# frozen_string_literal: true

require './lib/king'

RSpec.describe King do
  subject(:king) { described_class.new(1) }

  describe '#initialize' do
    context 'when the first player is generated' do
      context 'when a king piece is initialized' do
        it 'returns first move as true' do
          expect(king.first_move).to be(true)
        end

        it 'returns continuous move as true' do
          expect(king.continuous_movement).to be(false)
        end

        it 'returns its respective possible moves' do
          moves = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
          expect(king.possible_moves).to eq(moves)
        end

        it 'returns [0, 6] as king castling' do
          expect(king.king_castling).to eq([0, 6])
        end

        it 'returns [0, 2] as queen castling' do
          expect(king.queen_castling).to eq([0, 2])
        end
      end
    end

    context 'when the second player is generated' do
      let(:king2) { described_class.new(2) }
      context 'when a king piece is initialized' do
        it 'returns first move as true' do
          expect(king2.first_move).to be(true)
        end

        it 'returns continuous move as true' do
          expect(king2.continuous_movement).to be(false)
        end

        it 'returns its respective possible moves' do
          moves = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
          expect(king2.possible_moves).to eq(moves)
        end

        it 'returns [7, 6] as king castling' do
          expect(king2.king_castling).to eq([7, 6])
        end

        it 'returns [7, 2] as queen castling' do
          expect(king2.queen_castling).to eq([7, 2])
        end
      end
    end
  end
end
