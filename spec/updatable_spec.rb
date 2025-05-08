# frozen_string_literal: true

require './lib/updatable'
require './lib/conditionable'
require './lib/traceable'
require './lib/exceptionable'
require './lib/configurable'
require './lib/player'
require './lib/board'
require './lib/visualizable'

RSpec.describe Updatable do
  let(:game) { Game.new }
  let(:player1) { game.player1 }
  let(:player2) { game.player2 }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")

    allow($stdout).to receive(:write)
  end

  matcher :be_unicode do |char|
    match { |p| p.unicode == char }
  end

  describe '#update_non_castling_notation' do
    context 'when the knight of player one at g8 moves to f6' do
      let(:piece) { player1.knight[1] }
      let(:destination) { [5, 5] }
      let(:action) { game.update_non_castling_notation(player1, PIECE_STATS, piece, destination, nil) }

      it "changes the notation to ['N', nil, nil, 'f6', '', nil]" do
        notation = ['N', nil, nil, 'f6', nil]
        expect{ action }.to change{ player1.notation }.to(notation)
      end
    end

    context 'when the pawn of player two at e4 makes an en passant move to f3' do
      before do
        game.board.layout[3][4] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[3][4].current_position = [3, 4]

        game.board.layout[3][5] = game.board.layout[1][5]
        game.board.layout[1][5] = nil
        game.board.layout[3][5].current_position = [3, 5]
        game.board.layout[3][5].double_step[1] = true
      end
      let(:piece) { player2.pawn[4] }
      let(:destination) { [2, 5] }
      let(:action) { game.update_non_castling_notation(player2, PIECE_STATS, piece, destination, nil) }

      it "changes the notation to [nil, 'e', 'x', 'f3 e.p.', nil]" do
        notation = [nil, 'e', 'x', 'f3 e.p.', nil]
        expect{ action }.to change{ player2.notation }.to(notation)
      end
    end

    context 'when the two rooks of player one at a1 and a5 are qualified for moving to a3' do
      before do
        game.board.layout[1][0].current_position = nil
        game.board.layout[1][0] = nil

        game.board.layout[1][7].current_position = nil
        game.board.layout[1][7] = nil

        game.board.layout[4][0] = game.board.layout[0][7]
        game.board.layout[0][7] = nil
        game.board.layout[4][0].current_position = [4, 0]
      end

      let(:destination) { [2, 0] }

      context 'when the rook at a5 is selected' do
        let(:piece) { player1.rook[1] }
        let(:action) { game.update_non_castling_notation(player1, PIECE_STATS, piece, destination, nil) }

        it "changes the notation to ['R', '5', nil, 'a3', nil]" do
          notation = ['R', '5', nil, 'a3', nil]
          expect{ action }.to change{ player1.notation }.to(notation)
        end
      end

      context 'when the rook at a1 is selected' do
        let(:piece) { player1.rook[0] }
        let(:action) { game.update_non_castling_notation(player1, PIECE_STATS, piece, destination, nil) }

        it "changes the notation to ['R', '5', nil, 'a3', nil]" do
          notation = ['R', '1', nil, 'a3', nil]
          expect{ action }.to change{ player1.notation }.to(notation)
        end
      end
    end

    context 'when both knights of player two at c6 and g8 are qualified for moving to e7' do
      before do
        game.board.layout[6][4].current_position = nil
        game.board.layout[6][4] = nil

        game.board.layout[5][2] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[5][2].current_position = [5, 2]
      end

      let(:destination) { [6, 4] }

      context 'when the knight at c6 is selected' do
        let(:piece) { player2.knight[0] }
        let(:action) { game.update_non_castling_notation(player2, PIECE_STATS, piece, destination, nil) }

        it "changes the notation to ['N', 'c6', nil, 'e7', nil]" do
          notation = ['N', 'c6', nil, 'e7', nil]
          expect{ action }.to change{ player2.notation }.to(notation)
        end
      end

      context 'when the knight at g8 is selected' do
        let(:piece) { player2.knight[1] }
        let(:action) { game.update_non_castling_notation(player2, PIECE_STATS, piece, destination, nil) }

        it "changes the notation to ['N', 'g8', nil, 'e7', nil]" do
          notation = ['N', 'g8', nil, 'e7', nil]
          expect{ action }.to change{ player2.notation }.to(notation)
        end
      end
    end

    context 'when the knight of player one at g8 moves to f6' do
      before do
        game.board.layout[6][7].current_position = nil
        game.board.layout[6][7] = nil

        game.board.layout[6][7] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[6][7].current_position = [6, 7]
      end

      let(:piece) { player1.pawn[6] }
      let(:destination) { [7, 7] }
      let(:promoted_piece) { player1.queen[0] }
      let(:action) { game.update_non_castling_notation(player1, PIECE_STATS, piece, destination, promoted_piece) }

      it "changes the notation to [nil, nil, 'x, 'h8', '=Q']" do
        notation = [nil, nil, 'x', 'h8', '=Q']
        expect{ action }.to change{ player1.notation }.to(notation)
      end
    end
  end

  describe '#location_notation' do
    context 'when the knight of player one at g1 moves to f3' do
      it 'returns the notation f3' do
        expect(game.location_notation(player1, [2, 5])).to eq('f3')
      end
    end

    context 'when the knight of player two at g1 moves to f3' do
      before do
        game.board.layout[4][0] = game.board.layout[6][0]
        game.board.layout[6][0] = nil
        game.board.layout[4][0].current_position = [4, 0]

        game.board.layout[3][1] = game.board.layout[1][1]
        game.board.layout[1][1] = nil
        game.board.layout[3][1].current_position = [3, 1]
        game.board.layout[3][1].double_step[1] = true
      end
      it 'returns the notation b3 e.p.' do
        expect(game.location_notation(player2, [2, 1])).to eq('b3 e.p.')
      end
    end

    context 'when the pawn of player one at c5 makes an en passant move to b6' do
      before do
        game.board.layout[4][2] = game.board.layout[1][2]
        game.board.layout[1][2] = nil
        game.board.layout[4][2].current_position = [4, 2]

        game.board.layout[4][1] = game.board.layout[6][1]
        game.board.layout[6][1] = nil
        game.board.layout[4][1].current_position = [4, 1]
        game.board.layout[4][1].double_step[1] = true
      end

      it 'returns the notation b7 e.p.' do
        expect(game.location_notation(player1, [5, 1])).to eq('b6 e.p.')
      end
    end

    context 'when the bishop of player two at f8 moves to c5' do
      before do
        game.board.layout[4][4] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[4][4].current_position = [4, 4]
      end

      it 'returns the notation c5' do
        expect(game.location_notation(player2, [4, 2])).to eq('c5')
      end
    end
  end

  describe '#update_castling_notation' do
    context 'when player one chooese to perform queenside castling' do
      it 'returns 0-0-0' do
        expect(game.update_castling_notation(player1, '0-0-0')).to eq('0-0-0')
      end
    end

    context 'when player two chooese to perform queenside castling' do
      it 'returns 0-0-0' do
        expect(game.update_castling_notation(player1, 'O-O-O')).to eq('O-O-O')
      end
    end

    context 'when player one chooese to perform kingside castling' do
      it 'returns O-O' do
        expect(game.update_castling_notation(player1, 'O-O')).to eq('O-O')
      end
    end

    context 'when player two chooese to perform kingside castling' do
      it 'returns 0-0' do
        expect(game.update_castling_notation(player1, '0-0')).to eq('0-0')
      end
    end
  end

  describe '#en_passant_notation' do
    context 'when the pawn of player 2 at b4 performs an en passant move to the pawn at c4' do
      before do
        game.board.layout[3][1] = game.board.layout[6][1]
        game.board.layout[6][1] = nil
        game.board.layout[3][1].current_position = [3, 1]

        game.board.layout[3][2] = game.board.layout[1][2]
        game.board.layout[1][2] = nil
        game.board.layout[3][2].current_position = [3, 2]
        game.board.layout[3][2].double_step[1] = true
      end

      it 'returns e.p.' do
        expect(game.en_passant_notation(player2, [2, 2])).to eq(' e.p.')
      end
    end

    context 'when the pawn of player 1 at g2 moves to h3 where there is an opponent' do
      before do
        game.board.layout[2][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[2][7].current_position = [2, 7]
      end

      it 'returns nil' do
        expect(game.en_passant_notation(player1, [2, 7])).to be_nil
      end
    end

    context 'when the pawn of player 2 at e7 moves to e5' do
      it 'returns nil' do
        expect(game.en_passant_notation(player2, [4, 4])).to be_nil
      end
    end

    context 'when the pawn of player 1 at d5 performs an en passant move to the pawn at e5' do
      before do
        game.board.layout[4][3] = game.board.layout[1][3]
        game.board.layout[1][3] = nil
        game.board.layout[4][3].current_position = [4, 3]

        game.board.layout[4][4] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[4][4].current_position = [4, 4]
        game.board.layout[4][4].double_step[1] = true
      end

      it 'returns e.p.' do
        expect(game.en_passant_notation(player1, [5, 4])).to eq(' e.p.')
      end
    end
  end

  describe '#capture_notation' do
    context 'when the pawn of player one at e2 moves to e3' do
      it 'does not returns the x notation' do
        expect(game.capture_notation(player1, player1.pawn[4], [2, 4])).to be_nil
      end
    end

    context 'when the pawn of player two at a4 make an en passant move to b3' do
      before do
        game.board.layout[3][0] = game.board.layout[7][0]
        game.board.layout[7][0] = nil
        game.board.layout[3][0].current_position = [3, 0]

        game.board.layout[3][1] = game.board.layout[1][1]
        game.board.layout[1][1] = nil
        game.board.layout[3][1].current_position = [3, 1]
        game.board.layout[3][1].double_step[1] = true
      end
      it 'returns the x notation' do
        expect(game.capture_notation(player2, player2.pawn[0], [2, 1])).to eq('x')
      end
    end

    context 'when the bishop of player one at g5 captures the pawn at e7' do
      before do
        game.board.layout[3][3] = game.board.layout[1][3]
        game.board.layout[1][3] = nil
        game.board.layout[3][3].current_position = [3, 3]

        game.board.layout[4][6] = game.board.layout[0][2]
        game.board.layout[0][2] = nil
        game.board.layout[4][6].current_position = [4, 6]
      end
      it 'returns the x notation' do
        expect(game.capture_notation(player1, player1.bishop[0], [6, 4])).to eq('x')
      end
    end

    context 'when the pawn of player two d2 is promoted to e1 as a queen' do
      before do
        game.board.layout[1][3].current_position = nil
        game.board.layout[1][3] = game.board.layout[6][2]
        game.board.layout[6][2] = nil
        game.board.layout[1][3].current_position = [1, 3]
      end
      it 'returns the x notation' do
        expect(game.capture_notation(player2, player2.pawn[3], [0, 4])).to eq('x')
      end
    end
  end

  describe '#promotion_notation' do
    context 'when the knight piece is selected' do
      it 'returns =N' do
        expect(game.promotion_notation(PIECE_STATS, player1.knight[0])).to eq('=N')
      end
    end

    context 'when the rook piece is selected' do
      it 'returns =R' do
        expect(game.promotion_notation(PIECE_STATS, player2.rook[1])).to eq('=R')
      end
    end

    context 'when the bishop piece is selected' do
      it 'returns =B' do
        expect(game.promotion_notation(PIECE_STATS, player1.bishop[1])).to eq('=B')
      end
    end

    context 'when the queen piece is selected' do
      it 'returns =Q' do
        expect(game.promotion_notation(PIECE_STATS, player2.queen[0])).to eq('=Q')
      end
    end

    context 'when the pawn piece is selected' do
      it 'returns =' do
        expect(game.promotion_notation(PIECE_STATS, player1.pawn[4])).to eq('=')
      end
    end

    context 'when no pieces are selected' do
      it 'returns nil' do
        expect(game.promotion_notation(PIECE_STATS, nil)).to be_nil
      end
    end
  end

  describe '#origin_notation' do
    context 'when the pawn of player one at b2 attempt to move to b5' do
      let(:destination) { [4, 1] }
      it 'returns nil' do
        expect(game.selected_locations(player1, player1.pawn[2], destination)).to be_empty
        expect(game.origin_notation(player1, player1.pawn[2], destination)).to be_nil
      end
    end

    context 'when the rook of player two at a8 attempt to move to a6' do
      before do
        game.board.layout[4][0] = game.board.layout[6][0]
        game.board.layout[6][0] = nil
        game.board.layout[4][0].current_position = [4, 0]
      end

      let(:destination) { [5, 0] }
      it 'returns nil' do
        expect(game.selected_locations(player2, player2.rook[0], destination)).to eq([[7, 0]])
        expect(game.origin_notation(player2, player2.rook[0], destination)).to be_nil
      end
    end

    context 'when the knight at c3 and the knight at g1 can both move to e2' do
      before do
        game.board.layout[1][3].current_position = nil
        game.board.layout[1][3] = nil

        game.board.layout[2][2] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[2][2].current_position = [2, 2]

        allow(game).to receive(:selected_locations).and_return([[2, 2], [0, 6]])
      end
      let(:destination) { [1, 4] }

      it 'returns c3 if the knight at c3 is specified' do
        expect(game.origin_notation(player1, player1.knight[0], destination)).to eq('c3')
      end

      it 'returns c3 if the knight at c3 is specified' do
        expect(game.origin_notation(player1, player1.knight[1], destination)).to eq('g1')
      end

    end

    context 'when the rook at a8 and the rook at h8 can both move to e8' do
      before do
        0.upto(7) do |idx|
          unless[0, 4, 7].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[6][4] = game.board.layout[7][4]
        game.board.layout[7][4] = nil
        game.board.layout[6][4].current_position = [6, 4]

        allow(game).to receive(:selected_locations).and_return([[7, 0], [7, 7]])
      end
      let(:destination) { [7, 4] }

      it 'returns a if the rook at a8 is specified' do
        expect(game.origin_notation(player2, player2.rook[0], destination)).to eq('a')
      end

      it 'returns h if the rook at h8 is specified' do
        expect(game.origin_notation(player2, player2.rook[1], destination)).to eq('h')
      end
    end

    context 'when the knight at f5 and the knight at f3 can both move to d4' do
      before do
        game.board.layout[2][6] = game.board.layout[0][6]
        game.board.layout[0][6] = nil
        game.board.layout[2][6].current_position = [2, 6]

        game.board.layout[4][6] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[4][6].current_position = [4, 6]

        allow(game).to receive(:selected_locations).and_return([[2, 6], [4, 6]])
      end
      let(:destination) { [3, 3] }

      it 'returns 5 if the knight at f5 is specified' do
        expect(game.origin_notation(player1, player1.knight[0], destination)).to eq('5')
      end

      it 'returns 3 if the knight at f3 is specified' do
        expect(game.origin_notation(player1, player1.knight[1], destination)).to eq('3')
      end
    end

    context 'when the pawn at h4 performs an en passant move to g3' do
      before do
        game.board.layout[3][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[3][7].current_position = [3, 7]

        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]
        game.board.layout[3][6].double_step[1] = true

      end
      let(:destination) { [2, 6] }

      it 'returns h for the pawn' do
        expect(game.origin_notation(player2, player2.pawn[7], destination)).to eq('h')
      end
    end
  end

  describe '#assign_origin' do
    context 'when the pawn at d5 and the pawn at f5 can both move to e6' do
      before do
        game.board.layout[4][3] = game.board.layout[1][3]
        game.board.layout[1][3] = nil
        game.board.layout[4][3].current_position = [4, 3]

        game.board.layout[4][5] = game.board.layout[1][5]
        game.board.layout[1][5] = nil
        game.board.layout[4][5].current_position = [4, 5]

      end
      let(:locations) { [[4, 3], [4, 5]] }
      let(:destination) { [5, 4] }

      it 'returns d for the pawn at d5' do
        expect(game.location_notation(player1, player1.pawn[3].current_position)).to eq('d5')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(true)
        expect(game.en_passant?(player1, destination)).to be(false)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(false)
        expect(game.assign_origin(locations, player1, player1.pawn[3], destination)).to eq('d')
      end

      it 'returns f for the pawn at f5' do
        expect(game.location_notation(player1, player1.pawn[5].current_position)).to eq('f5')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(true)
        expect(game.en_passant?(player1, destination)).to be(false)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(false)
        expect(game.assign_origin(locations, player1, player1.pawn[5], destination)).to eq('f')
      end
    end

    context 'when the pawn at d4 moves to e5 with en passant' do
      before do
        game.board.layout[3][3] = game.board.layout[6][3]
        game.board.layout[6][3] = nil
        game.board.layout[3][3].current_position = [3, 3]

        game.board.layout[3][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[3][4].current_position = [3, 4]
        game.board.layout[3][4].double_step[1] = true

      end
      let(:locations) { [[3, 3], [3, 4]] }
      let(:destination) { [2, 4] }

      it 'returns d for the pawn at d4' do
        expect(game.location_notation(player2, player2.pawn[3].current_position)).to eq('d4')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(true)
        expect(game.en_passant?(player2, destination)).to be(true)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(false)
        expect(game.assign_origin(locations, player2, player2.pawn[3], destination)).to eq('d')
      end

    end

    context 'when the pawn at h5 moves to g5 with en passant' do
      before do
        game.board.layout[4][7] = game.board.layout[1][7]
        game.board.layout[1][7] = nil
        game.board.layout[4][7].current_position = [4, 7]

        game.board.layout[4][6] = game.board.layout[6][6]
        game.board.layout[6][6] = nil
        game.board.layout[4][6].current_position = [4, 6]
        game.board.layout[4][6].double_step[1] = true

      end
      let(:locations) { [[4, 7]] }
      let(:destination) { [5, 6] }

      it 'returns h for the pawn at h5' do
        expect(game.location_notation(player1, player1.pawn[7].current_position)).to eq('h5')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(true)
        expect(game.en_passant?(player1, destination)).to be(true)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(true)
        expect(game.assign_origin(locations, player1, player1.pawn[7], destination)).to eq('h')
      end

    end

    context 'when the knight at b6 and the knight at b4 can both move to d5' do
      before do
        game.board.layout[3][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[3][2].current_position = [3, 2]

        game.board.layout[5][2] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[5][2].current_position = [5, 2]

      end
      let(:locations) { [[5, 2], [3, 2]] }
      let(:destination) { [4, 4] }

      it 'returns 6 for the knight at c6' do
        expect(game.location_notation(player2, player2.knight[0].current_position)).to eq('c6')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(false)
        expect(game.en_passant?(player2, destination)).to be(false)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(true)
        expect(game.assign_origin(locations, player2, player2.knight[0], destination)).to eq('6')
      end

      it 'returns 4 for the knight at c4' do
        expect(game.location_notation(player2, player2.knight[1].current_position)).to eq('c4')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(false)
        expect(game.en_passant?(player2, destination)).to be(false)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(true)
        expect(game.assign_origin(locations, player2, player2.knight[1], destination)).to eq('4')
      end
    end

    context 'when the knight at c3 and the knight at g1 can both move to e2' do
      before do
        game.board.layout[1][3].current_position = nil
        game.board.layout[1][3] = nil

        game.board.layout[2][2] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[2][2].current_position = [2, 2]
      end
      let(:locations) { [[2, 2], [0, 6]] }
      let(:destination) { [1, 3] }

      it 'returns c3 for the knight at c3' do
        expect(game.location_notation(player1, player1.knight[0].current_position)).to eq('c3')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(false)
        expect(game.en_passant?(player1, destination)).to be(false)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(false)
        expect(game.assign_origin(locations, player1, player1.knight[0], destination)).to eq('c3')
      end

      it 'returns g1 for the knight at g1' do
        expect(game.location_notation(player1, player1.knight[1].current_position)).to eq('g1')
        expect(locations.all? { |x, _y| x == locations[0][0] }).to be(false)
        expect(game.en_passant?(player1, destination)).to be(false)
        expect(locations.all? { |_x, y| y == locations[0][1] }).to be(false)
        expect(game.assign_origin(locations, player1, player1.knight[1], destination)).to eq('g1')
      end
    end
  end

  describe '#board_notation' do
    context 'when the location [0, 7] is selected' do
      it 'returns h1' do
        expect(game.board_notation([0, 7], game.board)).to eq(['h', 1])
      end
    end

    context 'when the location [4, 4] is selected' do
      it 'returns e5' do
        expect(game.board_notation([4, 4], game.board)).to eq(['e', 5])
      end
    end

    context 'when the location [9, 4] is selected' do
      it 'returns an invalid notation' do
        expect(game.board_notation([9, 4], game.board)).to eq(['e', nil])
      end
    end

    context 'when the location [81, 1000] is selected' do
      it 'returns nil' do
        expect(game.board_notation([81, 1000], game.board)).to all(be_nil)
      end
    end

    context 'when the location [4321, 5] is selected' do
      it 'returns an invalid notation' do
        expect(game.board_notation([4321, 5], game.board)).to eq(['f', nil])
      end
    end
  end

  describe '#selected_locations' do
    # context 'when the pawn of player one at e5 attempts to move to d6 with en passant' do
    #   before do
    #     game.board.layout[4][4] = game.board.layout[1][4]
    #     game.board.layout[1][4] = nil
    #     game.board.layout[4][4].current_position = [4, 4]

    #     game.board.layout[4][3] = game.board.layout[6][3]
    #     game.board.layout[6][3] = nil
    #     game.board.layout[4][3].current_position = [4, 3]
    #     game.board.layout[4][3].double_step[1] = true
    #   end

    #   it 'returns the current position e5 of the pawn' do
    #     expect(game.selected_locations(player1, player1.pawn[4], [5, 3])).to eq([[4, 4]])
    #   end
    # end

    context 'when the pawn of player two at f2 attempts to e1 with a promotion' do
      before do
        game.board.layout[1][5].current_position = nil
        game.board.layout[1][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[1][5].current_position = [1, 5]
      end

      it 'returns the current position f2 of the pawn' do
        expect(game.selected_locations(player2, player2.pawn[5], [0, 4])).to eq([[1, 5]])
      end
    end

    context 'when the rook of player one at a1 attempts to move to a3' do
      before do
        game.board.layout[3][0] = game.board.layout[1][0]
        game.board.layout[1][0] = nil
        game.board.layout[3][0].current_position = [3, 0]
      end
      it 'returns the current position a1 of the pawn' do
        expect(game.selected_locations(player1, player1.rook[0], [2, 0])).to eq([[0, 0]])
      end
    end


    context 'when the knight of player two at b8 attempts to move to c6' do
      it 'returns the current position b8 of the knight' do
        expect(game.selected_locations(player2, player2.knight[0], [5, 2])).to eq([[7, 1]])
      end
    end

    context 'when the queen of player one at c1 attempts to move to e3' do
      it 'returns empty as the queen at c1 is in the way' do
        expect(game.selected_locations(player1, player1.queen[0], [2, 4])).to be_empty
      end
    end

    context 'when the king of player two at e8 attempts to move out of the board' do
      it 'returns empty as it is an invalid move' do
        expect(game.selected_locations(player2, player2.king[0], [9, 4])).to be_empty
      end
    end
  end

  describe '#to_symbol' do
    context 'when the king is selected by player one' do
      it 'returns a king symbol' do
        expect(game.to_symbol(player1.king[0])).to be_a(Symbol)
      end
    end

    context 'when the queen is selected by player two' do
      it 'returns a queen symbol' do
        expect(game.to_symbol(player2.queen[0])).to be_a(Symbol)
      end
    end

    context 'when the rook is selected by player one' do
      it 'returns a rook symbol' do
        expect(game.to_symbol(player1.rook[1])).to be_a(Symbol)
      end
    end

    context 'when the bishop is selected by player two' do
      it 'returns a bishop symbol' do
        expect(game.to_symbol(player2.bishop[0])).to be_a(Symbol)
      end
    end

    context 'when the knight is selected by player one' do
      it 'returns a knight symbol' do
        expect(game.to_symbol(player1.knight[1])).to be_a(Symbol)
      end
    end
  end

  describe '#piece_notation' do
    context 'when the king of player 1 is selected' do
      it 'returns the letter K' do
        expect(game.piece_notation(PIECE_STATS, player1.king[0])).to eq('K')
      end
    end

    context 'when the queen of player 2 is selected' do
      it 'returns the letter Q' do
        expect(game.piece_notation(PIECE_STATS, player2.queen[0])).to eq('Q')
      end
    end

    context 'when the rook of player 1 is selected' do
      it 'returns the letter R' do
        expect(game.piece_notation(PIECE_STATS, player1.rook[1])).to eq('R')
      end
    end

    context 'when the bishop of player 2 is selected' do
      it 'returns the letter B' do
        expect(game.piece_notation(PIECE_STATS, player2.bishop[0])).to eq('B')
      end
    end

    context 'when the knight of player 1 is selected' do
      it 'returns the letter N' do
        expect(game.piece_notation(PIECE_STATS, player1.knight[0])).to eq('N')
      end
    end

    context 'when the pawn of player 2 is selected' do
      it 'returns nil' do
        expect(game.piece_notation(PIECE_STATS, player2.pawn[5])).to be_nil
      end
    end
  end

  describe '#possible_pieces' do
    context 'when the pawn of player 1 is selected' do
      it 'returns the pawns' do
        expect(game.possible_pieces(player1, player1.pawn[4])).to all(be_a(Pawn))
        expect(game.possible_pieces(player1, player1.pawn[4]).count).to eq(8)
        expect(game.possible_pieces(player1, player1.pawn[4])).to all(be_unicode('♙'))
      end
    end

    context 'when the king of player 2 is selected' do
      it 'returns the king' do
        expect(game.possible_pieces(player2, player2.king[0])).to all(be_a(King))
        expect(game.possible_pieces(player2, player2.king[0]).count).to eq(1)
        expect(game.possible_pieces(player2, player2.king[0])).to all(be_unicode('♚'))
      end
    end

    context 'when the queen of player 1 is selected' do
      it 'returns the queen' do
        expect(game.possible_pieces(player1, player1.queen[0])).to all(be_a(Queen))
        expect(game.possible_pieces(player1, player1.queen[0]).count).to eq(1)
        expect(game.possible_pieces(player1, player1.queen[0])).to all(be_unicode('♕'))
      end
    end

    context 'when the rook of player 2 is selected' do
      it 'returns the rooks' do
        expect(game.possible_pieces(player2, player2.rook[1])).to all(be_a(Rook))
        expect(game.possible_pieces(player2, player2.rook[1]).count).to eq(2)
        expect(game.possible_pieces(player2, player2.rook[1])).to all(be_unicode('♜'))
      end
    end
  end
end
