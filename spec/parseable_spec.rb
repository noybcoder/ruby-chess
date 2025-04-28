# frozen_string_literal: true

require './lib/parseable'
require './lib/player'

PIECE_STATS = {
  King: { rank_locations: [4], letter: 'K' }, # King starts at file e (position 4)
  Queen: { rank_locations: [3], letter: 'Q' }, # Queen starts at file d (position 3)
  Rook: { rank_locations: [0, 7], letter: 'R' }, # Rooks start at files a and h (positions 0 and 7)
  Bishop: { rank_locations: [2, 5], letter: 'B' }, # Bishops start at files c and f (positions 2 and 5)
  Knight: { rank_locations: [1, 6], letter: 'N' }, # Knights start at files b and g (positions 1 and 6)
  Pawn: { rank_locations: Array(0..7) } # Pawns are on all files (positions 0-7)
}.freeze

RSpec.describe Parseable do
  let(:dummy_class) do
    Class.new do
      include Parseable
    end.new
  end

  let(:player) { Player.new }
  let(:board) { Board.new }

  matcher :be_chess do |piece|
    match { |p| p.is_a?(piece) }
  end


  describe '#parse_piece' do
    before { Player.player_count = 0 }
    context 'when the command Kb2 is given' do
      it 'returns an one instance of King' do
        move_elements = ['K', '', 'x', 'e2', '', '']
        result = dummy_class.parse_piece(PIECE_STATS, move_elements, player)
        expect(result).to all(be_chess(King))
        expect(result.count).to eq(1)

      end
    end

    context 'when the letter R is selected' do
      it 'returns 2 instances of Rook' do
        move_elements = ['R', '', '', 'a4', '', '']
        result = dummy_class.parse_piece(PIECE_STATS, move_elements, player)
        expect(result).to all(be_chess(Rook))
        expect(result.count).to eq(2)
      end
    end

    context 'when the empty string is selected' do
      it 'returns 8 instances of Pawn' do
        move_elements = ['', '', '', 'e4', '', '']
        result = dummy_class.identify_piece(PIECE_STATS, move_elements, player)
        expect(result).to all(be_chess(Pawn))
        expect(result.count).to eq(8)
      end
    end
  end

  describe '#parse_origin' do
    before { Board.board_count = 0 }
    context 'when the rook at rank 1 is selected for the destination a3' do
      it 'returns [[0], [0]]' do
        expect(dummy_class.parse_origin(['R', '1', '', 'a3', '', ''], board)).to eq([[0], [0]])
      end
    end

    context 'when the rook at rank 8 is selected for the destination a3' do
      it 'returns [[7], [0]]' do
        expect(dummy_class.parse_origin(['R', '8', '', 'a3', '', ''], board)).to eq([[7], [0]])
      end
    end

    context 'when the pawn at file d is selected for the destination e5' do
      it 'returns [[3], [1]]' do
        expect(dummy_class.parse_origin(['', 'd', 'x', 'e5', '', ''], board)).to eq([[3], [1]])
      end
    end

    context 'when the knight at file c is selected for the destination e4' do
      it 'returns [[2], [1]]' do
        expect(dummy_class.parse_origin(['N', 'c', 'x', 'e4', '', ''], board)).to eq([[2], [1]])
      end
    end

    context 'when the queen at h4 is selected for the destination e1' do
      it 'returns [[3, 7], [0, 1]]' do
        expect(dummy_class.parse_origin(['Q', 'h4', '', 'e1', '', ''], board)).to eq([[3, 7], [0, 1]])
      end
    end

    context 'when the knight at c2 is selected for the destination e3' do
      it 'returns [[1, 2], [0, 1]]' do
        expect(dummy_class.parse_origin(['K', 'c2', '', 'd4', '', ''], board)).to eq([[1, 2], [0, 1]])
      end
    end

    describe '#parse_capture' do
      context 'when the rook at file d captures the piece at e5' do
        it 'returns x' do
          expect(dummy_class.parse_capture(['', 'd', 'x', 'e5', '', ''])).to eq('x')
        end
      end

      context 'when the rook at rank 8 is selected for the destination a3' do
        it 'returns empty string' do
          expect(dummy_class.parse_capture(['R', '8', '', 'a3', '', ''])).to be('')
        end
      end
    end

    describe '#parse_destination' do
      context 'when the rook at rank 8 is selected for the destination a3' do
        it 'returns [2, 0]' do
          expect(dummy_class.parse_destination(['R', '8', '', 'a3', '', ''], board)).to eq([2, 0])
        end
      end

      context 'when the pawn at file d is selected for the destination e5' do
        it 'returns [4, 4]' do
          expect(dummy_class.parse_destination(['', 'd', 'x', 'e5', '', ''], board)).to eq([4, 4])
        end
      end

      context 'when the pawn at file d is selected for the destination z11' do
        it 'returns [0, nil]' do
          expect(dummy_class.parse_destination(['', 'd', 'x', 'z11', '', ''], board)).to eq([0, nil])
        end
      end
    end

    describe '#parse_promotion' do
      before { Player.player_count = 0 }
      context 'when the pawn at f7 is promoted to a queen at e8' do
        it 'returns an instance of Queen' do
          move_elements = ['', 'e8', '', '', '=Q', '']
          result = dummy_class.parse_promotion(PIECE_STATS, move_elements, player)
          expect(result).to all be_chess(Queen)
          expect(result.count).to eq(1)
        end
      end

      context 'when the pawn at a7 is promoted to a bishop at b8' do
        it 'returns 2 instances of Bishop' do
          move_elements = ['', 'b8', '', '', '=B', '']
          result = dummy_class.parse_promotion(PIECE_STATS, move_elements, player)
          expect(result).to all be_chess(Bishop)
          expect(result.count).to eq(2)
        end
      end

      context 'when the pawn at h7 is promoted to a knight at g8' do
        it 'returns 2 instances of Knight' do
          move_elements = ['', 'b8', '', '', '=N', '']
          result = dummy_class.parse_promotion(PIECE_STATS, move_elements, player)
          expect(result).to all be_chess(Knight)
          expect(result.count).to eq(2)
        end
      end
    end

    describe '#parse_castling' do
      context 'when the first player is generated' do
        context 'when the queen castling is executed' do
          before { Player.player_count = 0 }
          let(:move_elements) { ['', '', '', '', '', '0-0-0'] }
          let(:result) { dummy_class.parse_castling(move_elements, player) }

          it 'returns an instance of King' do
            expect(result[0]).to be_chess(King)
            expect(result[0].current_position).to eq([0, 4])
            expect(result[0].queen_castling).to eq([0, 2])
            expect(result[0].king_castling).to eq([0, 6])
          end

          it 'returns the rook on the king side' do
            expect(result[1]).to be_chess(Rook)
            expect(result[1].current_position).to eq([0, 0])
            expect(result[1].queen_castling).to eq([0, 3])
            expect(result[1].king_castling).to eq([0, 5])
          end

          it 'returns O-O-O' do
            expect(result[-1]).to eq('O-O-O')
          end
        end

        context 'when the king castling is executed' do
          before { Player.player_count = 0 }
          let(:move_elements) { ['', '', '', '', '', 'O-O'] }
          let(:result) { dummy_class.parse_castling(move_elements, player) }

          it 'returns an instance of King' do
            expect(result[0]).to be_chess(King)
            expect(result[0].current_position).to eq([0, 4])
            expect(result[0].queen_castling).to eq([0, 2])
            expect(result[0].king_castling).to eq([0, 6])
          end

          it 'returns the rook on the king side' do
            expect(result[1]).to be_chess(Rook)
            expect(result[1].current_position).to eq([0, 7])
            expect(result[1].queen_castling).to eq([0, 3])
            expect(result[1].king_castling).to eq([0, 5])
          end

          it 'returns O-O' do
            expect(result[-1]).to eq('O-O')
          end
        end
      end

      context 'when the second player is generated' do
        before { Player.player_count = 1 }
        let(:player2) { Player.new }

        context 'when the queen castling is executed' do
          let(:move_elements) { ['', '', '', '', '', 'O-O-O'] }
          let(:result) { dummy_class.parse_castling(move_elements, player2) }

          it 'returns an instance of King' do
            expect(result[0]).to be_chess(King)
            expect(result[0].current_position).to eq([7, 4])
            expect(result[0].queen_castling).to eq([7, 2])
            expect(result[0].king_castling).to eq([7, 6])
          end

          it 'returns the rook on the queen side' do
            expect(result[1]).to be_chess(Rook)
            expect(result[1].current_position).to eq([7, 0])
            expect(result[1].queen_castling).to eq([7, 3])
            expect(result[1].king_castling).to eq([7, 5])
          end

          it 'returns O-O-O' do
            expect(result[-1]).to eq('O-O-O')
          end
        end

        context 'when the king castling is executed' do
          let(:move_elements) { ['', '', '', '', '', 'O-O'] }
          let(:result) { dummy_class.parse_castling(move_elements, player2) }

          it 'returns an instance of King' do
            expect(result[0]).to be_chess(King)
            expect(result[0].current_position).to eq([7, 4])
            expect(result[0].queen_castling).to eq([7, 2])
            expect(result[0].king_castling).to eq([7, 6])
          end

          it 'returns the rook on the king side' do
            expect(result[1]).to be_chess(Rook)
            expect(result[1].current_position).to eq([7, 7])
            expect(result[1].queen_castling).to eq([7, 3])
            expect(result[1].king_castling).to eq([7, 5])
          end

          it 'returns O-O' do
            expect(result[-1]).to eq('O-O')
          end
        end
      end
    end
  end
end
