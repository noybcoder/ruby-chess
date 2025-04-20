# frozen_string_literal: true

require './lib/pawn'

RSpec.describe Pawn do
  subject(:pawn) { described_class.new(1) }

  describe '#initialize' do
    context 'when the first player is generated' do
      context 'when a pawn piece is initialized' do
        it 'returns first move as true' do
          expect(pawn.first_move).to be(true)
        end

        it 'returns continuous move as true' do
          expect(pawn.continuous_movement).to be(true)
        end

        it 'returns its respective possible moves' do
          moves = [[1, 0]]
          expect(pawn.possible_moves).to eq(moves)
        end

        it 'returns its respective capture moves' do
          moves = [[1, -1], [1, 1]]
          expect(pawn.capture_moves).to eq(moves)
        end

        it 'returns its respective promotion rank' do
          expect(pawn.instance_variable_get(:@promotion_rank)).to eq(6)
        end

        it 'returns its respective double step' do
          expect(pawn.double_step).to eq([[], false])
        end
      end
    end

    context 'when the second player is generated' do
      let(:pawn2) { described_class.new(2) }
      context 'when a pawn piece is initialized' do
        it 'returns first move as true' do
          expect(pawn2.first_move).to be(true)
        end

        it 'returns continuous move as true' do
          expect(pawn2.continuous_movement).to be(true)
        end

        it 'returns its respective possible moves' do
          moves = [[-1, 0]]
          expect(pawn2.possible_moves).to eq(moves)
        end

        it 'returns its respective capture moves' do
          moves = [[-1, 1], [-1, -1]]
          expect(pawn2.capture_moves).to eq(moves)
        end

        it 'returns its respective promotion rank' do
          expect(pawn2.instance_variable_get(:@promotion_rank)).to eq(1)
        end

        it 'returns its respective double step' do
          expect(pawn2.double_step).to eq([[], false])
        end
      end
    end
  end

  describe '#reset_moves' do
    context 'when the method is called and the first move is true' do
      it 'changes the first move flag from true to false' do
        expect { pawn.reset_moves }.to change(pawn, :first_move).from(true).to(false)
      end
    end

    context 'when the method is called and the first move is false' do
      it 'does not change the first move flag' do
        pawn.instance_variable_set(:@first_move, false)
        expect { pawn.reset_moves }.not_to change(pawn, :first_move)
      end
    end
  end

  describe '#promoted_position?' do
    context 'when the first player is generated' do
      context 'when the pawn piece is first created' do
        it 'returns false' do
          expect(pawn.promoted_position?).to be(false)
        end
      end

      context 'when the pawn piece is at the promoted position' do
        it 'returns true' do
          pawn.instance_variable_set(:@current_position, [6, 5])
          expect(pawn.promoted_position?).to be(true)
        end
      end

      context 'when the pawn piece is not at the promoted position' do
        it 'returns false' do
          pawn.instance_variable_set(:@current_position, [5, 3])
          expect(pawn.promoted_position?).to be(false)
        end
      end
    end

    context 'when the second player is generated' do
      let(:pawn2) { described_class.new(2) }

      context 'when the pawn piece is first created' do
        it 'returns false' do
          expect(pawn2.promoted_position?).to be(false)
        end
      end

      context 'when the pawn piece is at the promoted position' do
        let(:pawn2) { described_class.new(2) }
        it 'returns true' do
          pawn2.instance_variable_set(:@current_position, [1, 4])
          expect(pawn2.promoted_position?).to be(true)
        end
      end

      context 'when the pawn piece is not at the promoted position' do
        let(:pawn2) { described_class.new(2) }
        it 'returns false' do
          pawn2.instance_variable_set(:@current_position, [4, 4])
          expect(pawn2.promoted_position?).to be(false)
        end
      end
    end
  end
end
