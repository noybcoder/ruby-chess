# frozen_string_literal: true

require './lib/rook'

RSpec.describe Rook do
  subject(:rook) { described_class.new(1) }

  describe '#initialize' do
    context 'when the first player is generated' do
      context 'when a rook piece is initialized' do
        it 'returns first move as true' do
          expect(rook.first_move).to be(true)
        end

        it 'returns continuous move as true' do
          expect(rook.continuous_movement).to be(true)
        end

        it 'returns its respective possible moves' do
          moves = [[1, 0], [0, 1], [-1, 0], [0, -1]]
          expect(rook.possible_moves).to eq(moves)
        end

        it 'returns [0, 3] as king castling' do
          expect(rook.king_castling).to eq([0, 5])
        end

        it 'returns [0, 5] as queen castling' do
          expect(rook.queen_castling).to eq([0, 3])
        end
      end
    end

    context 'when the second player is generated' do
      let(:rook2) { described_class.new(2) }
      context 'when a rook piece is initialized' do
        it 'returns first move as true' do
          expect(rook2.first_move).to be(true)
        end

        it 'returns continuous move as true' do
          expect(rook.continuous_movement).to be(true)
        end

        it 'returns its respective possible moves' do
          moves = [[1, 0], [0, 1], [-1, 0], [0, -1]]
          expect(rook2.possible_moves).to eq(moves)
        end

        it 'returns [7, 3] as king castling' do
          expect(rook2.king_castling).to eq([7, 5])
        end

        it 'returns [7, 5] as queen castling' do
          expect(rook2.queen_castling).to eq([7, 3])
        end
      end
    end
  end

  describe '#reset_moves' do
    context 'when the first move of the rook piece is true' do
      it 'changes the first move to false' do
        expect { rook.reset_moves }.to change(rook, :first_move).from(true).to(false)
      end
    end

    context 'when the first move of the rook piece is false' do
      it 'does not changes the first move to false' do
        rook.instance_variable_set(:@first_move, false)
        expect { rook.reset_moves }.not_to change(rook, :first_move)
      end
    end
  end
end
