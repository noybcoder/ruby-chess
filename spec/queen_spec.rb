# frozen_string_literal: true

require './lib/queen'

RSpec.describe Queen do
  subject(:queen) { described_class.new }

  describe '#initialize' do
    context 'when a queen piece is initialized' do
      it 'returns first move as true' do
        expect(queen.first_move).to be(true)
      end

      it 'returns continuous move as true' do
        expect(queen.continuous_movement).to be(true)
      end

      it 'returns its respective possible moves' do
        moves = [[1, 0], [-1, 1], [0, 1], [1, 1], [-1, 0], [1, -1], [0, -1], [-1, -1]]
        expect(queen.possible_moves).to eq(moves)
      end
    end
  end
end
