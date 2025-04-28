# frozen_string_literal: true

require './lib/computer'
require './lib/errors'

RSpec.describe Computer do
  before { Player.player_count = 0 }

  subject(:computer) { described_class.new }

  describe '#initialize' do
    context 'when a computer player is first generated' do
      it 'returns nil for the available_destinations' do
        expect(computer.available_destinations).to be_nil
      end
    end

    context 'when the available_destinations is updated' do
      let(:locations) { [[3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7]] }

      before { computer.available_destinations = locations }
      it 'returns the updated available_destiantions' do
        expect(computer.available_destinations).to be(locations)
      end
    end
  end

  describe '#random_destination' do
    context 'when there is no available destinations' do
      before do
        computer.available_destinations = []
      end

      it 'returns nil' do
        expect(computer.random_destination).to be_nil
      end
    end

    context 'when there are available destinations' do
      let(:locations) { [[4, 0], [4, 1], [4, 2], [4, 3], [4, 4]] }
      before { computer.available_destinations = locations }

      it 'returns a randomly selected location from the available destinations' do
        expect([computer.random_destination].size).to eq(1)
        expect(locations.include?(computer.random_destination)).to be(true)
      end
    end
  end

  describe '#available_pieces' do
    context 'when the computer player is first generated' do
      it 'returns all available pieces' do
        expect(computer.available_pieces.count).to eq(16)
      end
    end

    context 'when 3 of the computer\'s pieces are captured' do
      before do
        computer.rook[0].current_position = nil
        computer.knight[1].current_position = nil
        computer.queen[0].current_position = nil
      end

      it 'returns 13 as the available pieces' do
        expect(computer.available_pieces.count).to eq(13)
      end
    end

    context 'when all of the computer\'s pieces are captured' do
      before do
        computer.retrieve_pieces.each { |piece| piece.current_position = nil }
      end

      it 'returns 0 as the available pieces' do
        expect(computer.available_pieces.count).to eq(0)
      end
    end
  end

  describe '#pick_promoted_piece' do
    context 'when a promotion is valid and computer picks the piece randomly' do
      it 'returns one of the queen, rook bishop, knight] pieces' do
        expect([Queen, Rook, Bishop, Knight].include?(computer.pick_promoted_piece[0].class)).to be(true)
      end
    end
  end

  describe '#available_castling_types' do
    context 'when both rooks and the king are still around' do
      it 'returns both king_castling and queen_castling' do
        expect(computer.available_castling_types).to contain_exactly('king_castling', 'queen_castling')
      end
    end

    context 'when the rook on the queen side is removed' do
      it 'returns king castling' do
        computer.rook[0].current_position = nil
        expect(computer.available_castling_types).to eq(['king_castling'])
      end
    end

    context 'when the rook on the king side is removed' do
      it 'returns queen castling' do
        computer.rook[1].current_position = nil
        expect(computer.available_castling_types).to eq(['queen_castling'])
      end
    end
  end

  describe '#valid_castling' do
    context 'when both rooks and the king are still around' do
      it 'returns the positions of the king and one of rooks and the king or queen castling notation' do
        expect(computer.valid_castling[0].current_position).to eq([0, 4])
        expect([[0, 0], [0, 7]].include?(computer.valid_castling[1].current_position)).to be(true)
        expect(['O-O', 'O-O-O'].include?(computer.valid_castling[-1])).to be(true)
      end
    end

    context 'when the rook on the king side is removed' do
      it 'returns the positions of the king and the rook (queen side) and the queen castling notation' do
        computer.rook[1].current_position = nil
        expect(computer.valid_castling[0].current_position).to eq([0, 4])
        expect(computer.valid_castling[1].current_position).to eq([0, 0])
        expect(computer.valid_castling[-1]).to eq('O-O-O')
      end
    end

    context 'when the rook on the king side is removed' do
      it 'returns the positions of the king and the rook (king side) and the king castling notation' do
        computer.rook[0].current_position = nil
        expect(computer.valid_castling[0].current_position).to eq([0, 4])
        expect(computer.valid_castling[1].current_position).to eq([0, 7])
        expect(computer.valid_castling[-1]).to eq('O-O')
      end
    end
  end
end
