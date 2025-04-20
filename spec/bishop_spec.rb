# frozen_string_literal: true

require './lib/bishop'

RSpec.describe Bishop do
  subject(:bishop) { described_class.new }

  describe '#initialize' do
    context 'when a bishop piece is initialized' do
      it 'returns first move as true' do
        expect(bishop.first_move).to be(true)
      end

      it 'returns continuous move as true' do
        expect(bishop.continuous_movement).to be(true)
      end

      it 'returns its respective possible moves' do
        expect(bishop.possible_moves).to eq([[1, 1], [-1, 1], [-1, -1], [1, -1]])
      end
    end
  end
end
