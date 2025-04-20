# frozen_string_literal: true

require './lib/knight'

RSpec.describe Knight do
  subject(:knight) { described_class.new }

  describe '#initialize' do
    context 'when a knight piece is initialized' do
      it 'returns first move as true' do
        expect(knight.first_move).to be(true)
      end

      it 'returns continuous move as true' do
        expect(knight.continuous_movement).to be(false)
      end

      it 'returns its respective possible moves' do
        moves = [[2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-1, -2], [1, -2], [2, -1]]
        expect(knight.possible_moves).to eq(moves)
      end
    end
  end
end
