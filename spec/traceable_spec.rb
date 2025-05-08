# frozen_string_literal: true

RSpec.describe Traceable do
  let(:game) { Game.new }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")

    allow($stdout).to receive(:write)
  end

  describe '#game_paths' do
    let(:player1) { game.player1 }
    let(:player2) { game.player2 }

    context 'when the pawn of player 1 at e2 captures the pawn at d3' do
      let(:destination) { [2, 3] }
      before do
        game.board.layout[2][3] = game.board.layout[6][3]
        game.board.layout[6][3] = nil
        game.board.layout[2][3].current_position = [2, 3]
      end

      it 'returns true' do
        piece = player1.pawn[4]
        expect(game.game_paths(piece, player1, destination)).to be(true)
      end
    end

    context 'when the king of player 2 at e8 attempts to move to e6' do
      let(:destination) { [5, 4] }
      before { allow(player2).to receive(:random_destination).and_return(destination) }

      it 'returns false' do
        piece = player2.king[0]
        expect(game.game_paths(piece, player2, destination)).to be(false)
      end
    end

    context 'when the pawn of player 1 at g4 moves to g5' do
      let(:destination) { [4, 6] }
      before do
        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]

        game.board.layout[4][6] = game.board.layout[6][6]
        game.board.layout[6][6] = nil
        game.board.layout[4][6].current_position = [4, 6]
      end

      it 'returns true' do
        piece = player1.pawn[6]
        expect(game.game_paths(piece, player1, destination)).to be(false)
      end
    end

    context 'when the pawn of player 2 at f7 attempts to move to f5' do
      let(:destination) { [4, 5] }
      before { allow(player2).to receive(:random_destination).and_return(destination) }

      it 'returns true' do
        piece = player2.pawn[5]
        expect(game.game_paths(piece, player2, destination)).to be(true)
      end
    end
  end

  describe '#combine_paths' do
    let(:player1) { game.player1 }
    let(:player2) { game.player2 }
    context 'when the knight of player one at g1 attempts to move to f3' do
      it 'returns the destination [[2, 5]]' do
        piece = player1.knight[1]
        moves = piece.possible_moves
        destination = [2, 5]

        expect(game.combine_paths(moves, piece, player1, destination)).to contain_exactly([destination])
      end
    end

    context 'when the queen of player two at d8 attempts to move to d3 but the moves are nil' do
      before { allow(player2).to receive(:random_destination).and_return([2, 3]) }
      it 'returns the []' do
        piece = player2.queen[0]
        destination = [2, 3]
        expect(game.combine_paths(nil, piece, player2, destination)).to be_empty
      end
    end

    context 'when the pawn of player one at f7 attempts to move to e8' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]
      end
      let(:piece) { player1.pawn[4] }
      let(:destination) { [7, 4] }

      context 'when the pawn uses capture moves' do
        let(:moves) { piece.capture_moves }

        it 'returns the destination [[7, 4]]' do
          expect(game.combine_paths(moves, piece, player1, destination)).to contain_exactly([destination])
        end
      end

      context 'when the pawn uses possible moves' do
        let(:moves) { piece.possible_moves }

        it 'returns []' do
          expect(game.combine_paths(moves, piece, player1, destination)).to be_empty
        end
      end
    end

    context 'when the destination is not specified and the queen of player two at h4 is selected' do
      before do
        game.board.layout[1][5].current_position = nil
        game.board.layout[1][5] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[1][5].current_position = [1, 5]

        game.board.layout[3][7] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[3][7].current_position = [3, 7]
      end
      it 'returns the possible moves the queen can make from h4' do
        piece = player2.queen[0]
        moves = piece.possible_moves
        output = [
          [[4, 7], [5, 7], [6, 7], [7, 7], [8, 7]], [[2, 8]], [[3, 8]],
          [[4, 8]], [[2, 7]], [[4, 6]], [[3, 6]], [[2, 6]]
        ]
        expect(game.combine_paths(moves, piece, player2)).to contain_exactly(*output)
      end
    end
  end

  describe '#pawn_blocked?' do
    context 'when the queen of player 1 at d1 attemps to move to d2' do
      it 'returns false on pawn block' do
        piece = game.player1.queen[0]
        path = [
          [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [5, 0], [7, 6], [6, 0],
          [6, 1], [6, 2], [4, 3], [6, 4], nil, [6, 6], [6, 7]
        ]
        locations = [[1, 3]]
        expect(!game.empty_path?(path, locations)).to be(false)
        expect(piece).not_to be_a(Pawn)
        expect(game.pawn_blocked?(path, locations, piece)).to be(false)
      end
    end

    context 'when the bishop of player two at c8 attemps to move to a6' do
      before do
        game.board.layout[4][1] = game.board.layout[6][1]
        game.board.layout[6][1] = nil
        game.board.layout[4][1].current_position = [4, 1]
        allow(game.player2).to receive(:random_destination).and_return([5, 0])
      end
      it 'returns false on pawn block' do
        piece = game.player2.bishop[0]
        path = [[6, 1], [5, 0]]
        locations = [[6, 1], [5, 0]]
        expect(!game.empty_path?(path, locations)).to be(true)
        expect(piece).not_to be_a(Pawn)
        expect(game.pawn_blocked?(path, locations, piece)).to be(false)
      end
    end

    context 'when the pawn of player 1 at c2 attemps to move to c4' do
      it 'returns false on pawn block' do
        piece = game.player1.pawn[2]
        path = [[2, 2], [3, 2], [4, 2], [5, 2], [6, 2], [7, 2]]
        locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6],
          [1, 0], [1, 1], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7], [7, 4],
          [7, 3], [7, 0], [7, 7], [7, 5], [7, 1], [7, 6], [6, 0], [6, 1],
          [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(!game.empty_path?(path, locations)).to be(false)
        expect(piece).to be_a(Pawn)
        expect(game.pawn_blocked?(path, locations, piece)).to be(false)
      end
    end

    context 'when the pawn of player two at f4 attemps to move to e3' do
      before do
        game.board.layout[3][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[3][5].current_position = [3, 5]

        game.board.layout[3][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[3][4].current_position = [3, 4]
        game.board.layout[3][4].double_step[1] = true

        allow(game.player2).to receive(:random_destination).and_return([2, 4])
      end
      it 'returns false on pawn block' do
        piece = game.player2.pawn[5]
        path = [[2, 4], [1, 3], [0, 2]]
        locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6],
          [1, 0], [1, 1], [1, 2], [1, 3], [3, 4], [1, 5], [1, 6], [1, 7],
          [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6],
          [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [3, 5], [6, 6], [6, 7]
        ]
        expect(!game.empty_path?(path, locations)).to be(true)
        expect(piece).to be_a(Pawn)
        expect(game.pawn_blocked?(path, locations, piece)).to be(true)
      end
    end
  end

  describe '#double_step?' do
    context 'when the pawn of player one at f2 attempts to move to f4' do
      it 'returns true' do
        expect(game.double_step?(game.player1.pawn[5], [3, 5])).to be(true)
      end
    end

    context 'when the pawn of player two at c7 attempts to move to c4' do
      before { allow(game.player2).to receive(:random_destination).and_return([3, 2]) }
      it 'returns false' do
        expect(game.double_step?(game.player2.pawn[2], [3, 2])).to be(false)
      end
    end

    context 'when the destination is nil' do
      it 'returns true' do
        expect(game.double_step?(game.player1.king[0], nil)).to be(true)
      end
    end

    context 'when the knight of player two at b8 attempts to move to c6' do
      before { allow(game.player2).to receive(:random_destination).and_return([5, 2]) }
      it 'returns true' do
        expect(game.double_step?(game.player2.knight[0], [5, 2])).to be(true)
      end
    end
  end

  describe '#piece_moves' do
    let(:player1) { game.player1 }
    let(:player2) { game.player2 }

    context 'when the knight of player one at a2 moves to a3' do
      let(:destination) { [2, 0] }
      let(:piece) { player1.pawn[0] }

      it 'returns false on capture moves and returns the possible moves of the knight' do
        expected_moves = piece.possible_moves
        expect(game.capture_moves?(player1, destination, piece)).to be(false)
        expect(game.piece_moves(player1, destination, piece)).to eq(expected_moves)
      end
    end

    context 'when the pawn of player two at c4 makes an en passant move to d3' do
      let(:destination) { [2, 3] }
      let(:piece) { player2.pawn[2] }

      before do
        game.board.layout[3][2] = game.board.layout[6][2]
        game.board.layout[6][2] = nil
        game.board.layout[3][2].current_position = [3, 2]

        game.board.layout[3][3] = game.board.layout[1][3]
        game.board.layout[1][3] = nil
        game.board.layout[3][3].current_position = [3, 3]
        game.board.layout[3][3].double_step[1] = true

        allow(player2).to receive(:random_destination).and_return(destination)
      end

      it 'returns true on capture moves and returns the capture moves of the pawn' do
        expected_moves = piece.capture_moves
        expect(game.capture_moves?(player2, destination, piece)).to be(true)
        expect(game.piece_moves(player2, destination, piece)).to eq(expected_moves)
      end
    end

    context 'when the pawn of player one at g2 makes an en passant move to h3' do
      let(:destination) { [2, 7] }
      let(:piece) { player1.pawn[6] }

      before do
        game.board.layout[2][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[2][7].current_position = [2, 7]
      end

      it 'returns true on capture moves and returns the capture moves of the pawn' do
        expected_moves = piece.capture_moves
        expect(game.capture_moves?(player1, destination, piece)).to be(true)
        expect(game.piece_moves(player1, destination, piece)).to eq(expected_moves)
      end
    end

    context 'when the pawn of player two at f7 moves to f6' do
      let(:destination) { [5, 5] }
      let(:piece) { player2.pawn[5] }
      before { allow(player2).to receive(:random_destination).and_return(destination) }

      it 'returns false on capture moves and returns the possible moves of the knight' do
        expected_moves = piece.possible_moves
        expect(game.capture_moves?(player2, destination, piece)).to be(false)
        expect(game.piece_moves(player2, destination, piece)).to eq(expected_moves)
      end
    end
  end

  describe '#capture_moves' do
    let(:player1) { game.player1 }
    let(:player2) { game.player2 }

    context 'when the pawn of player 1 at e5 is attempting an passant move to f6' do
      let(:destination) { [5, 5] }
      let(:piece) { player1.pawn[4] }

      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
        game.board.layout[4][5].double_step[1] = true
      end

      it 'returns false on pawn blocked, true on en passant and capture moves' do
        expect(game.pawn_blocked?(player2.piece_locations, [destination], piece)).to be(false)
        expect(game.en_passant?(player1, destination)).to be(true)
        expect(game.capture_moves?(player1, destination, piece)).to be(true)
      end
    end

    context 'when the pawn of player 2 at h7 is attempting to move to h5 but player one is in the way' do
      let(:destination) { [4, 7] }
      let(:piece) { player2.pawn[7] }
      before do
        game.board.layout[4][7] = game.board.layout[1][7]
        game.board.layout[1][7] = nil
        game.board.layout[4][7].current_position = [4, 7]
        allow(player2).to receive(:random_destination).and_return(destination)
      end
      it 'returns false on en passant but true on pawn blocked and capture moves' do
        expect(game.pawn_blocked?(player1.piece_locations, [destination], piece)).to be(true)
        expect(game.en_passant?(player2, destination)).to be(false)
        expect(game.capture_moves?(player2, destination, piece)).to be(true)
      end
    end

    context 'when the pawn of player 2 at f7 is attempting to move to f6' do
      let(:destination) { [5, 5] }
      let(:piece) { player2.pawn[5] }
      before { allow(player2).to receive(:random_destination).and_return(destination) }

      it 'returns false on pawn blocked, en passant and capture moves' do
        expect(game.pawn_blocked?(player1.piece_locations, [destination], piece)).to be(false)
        expect(game.en_passant?(player2, destination)).to be(false)
        expect(game.capture_moves?(player2, destination, piece)).to be(false)
      end
    end
  end

  describe '#build_path' do
    context 'when the pawn at g2 is looking for a path to g4' do
      let(:piece) { game.player1.pawn[6] }
      it 'returns [[2, 6], [3, 6]]' do
        path = [[2, 6], [3, 6]]
        action = game.build_path(piece.current_position, piece.possible_moves[0], piece, [3, 6])
        expect(action).to contain_exactly(*path)
      end
    end

    context 'when the pawn at g2 is looking for a path to g4' do
      let(:piece) { game.player2.queen[0] }
      let(:destination) { [4, 0] }
      before { allow(game.player2).to receive(:random_destination).and_return(destination) }
      it 'returns [[4, 0], [5, 1], [6, 2]]' do
        path = [[4, 0], [5, 1], [6, 2]]
        action = game.build_path(piece.current_position, piece.possible_moves[-1], piece, destination)
        expect(action).to contain_exactly(*path)
      end
    end

    context 'when the knight (captured) at g1 is looking for a path to h3' do
      let(:piece) { game.player1.knight[1] }
      it 'returns an empty array' do
        piece.current_position = nil
        action = game.build_path(piece.current_position, piece.possible_moves[0], piece, [2, 7])
        expect(action).to be_empty
      end
    end
  end

  describe '#met_path_conditions?' do
    context 'when the knight at g1 attempts to move to h3' do
      let(:piece) { game.player1.knight[1] }
      let(:location) { piece.current_position }
      let(:destination) { [2, 7] }
      it 'returns true on meeting path conditions' do
        expect(!piece.continuous_movement).to be(true)
        expect(!game.valid?(location)).to be(false)
        expect(location == destination).to eq(false)
        expect(game.met_path_conditions?(piece, location, destination)).to be(true)
      end
    end

    context 'when the king at e8 attempts to move to e8' do
      let(:piece) { game.player2.king[0] }
      let(:location) { piece.current_position }
      let(:destination) { [7, 4] }
      before { allow(game.player2).to receive(:random_destination).and_return([destination]) }
      it 'returns true on meeting path conditions' do
        expect(!piece.continuous_movement).to be(true)
        expect(!game.valid?(location)).to be(false)
        expect(location == destination).to eq(true)
        expect(game.met_path_conditions?(piece, location, destination)).to be(true)
      end
    end

    context 'when the pawn at h2 attempts to move to h6' do
      let(:piece) { game.player1.pawn[7] }
      let(:location) { [-1, 7] }
      let(:destination) { [3, 7] }

      it 'returns true on meeting path conditions' do
        expect(!piece.continuous_movement).to be(false)
        expect(!game.valid?(location)).to be(true)
        expect(location == destination).to eq(false)
        expect(game.met_path_conditions?(piece, location, destination)).to be(true)
      end
    end

    context 'when the pawn at e7 attempts to move to e5' do
      let(:piece) { game.player2.pawn[4] }
      let(:location) { piece.current_position }
      let(:destination) { [4, 4] }
      before { allow(game.player2).to receive(:random_destination).and_return([destination]) }
      it 'returns false on meeting path conditions' do
        expect(!piece.continuous_movement).to be(false)
        expect(!game.valid?(location)).to be(false)
        expect(location == destination).to eq(false)
        expect(game.met_path_conditions?(piece, location, destination)).to be(false)
      end
    end
  end

  describe '#unblocked_path?' do
    context 'when e8 is not occupied by the same player' do
      before do
        game.board.layout[6][3].current_position = nil
        game.board.layout[6][3] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][3].current_position = [6, 3]
      end

      context 'when the destination is set as e8' do
        it 'returns true on valid path, checking opponent and unblocked path' do
          destination = [7, 4]
          path = [[7, 4]]
          all_locations = [
            [0, 4], [0, 3], nil, [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0],
            [1, 1], [1, 2], [1, 3], [6, 3], [1, 5], [1, 6], [1, 7], [7, 4], [7, 3], [7, 0],
            [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [6, 0], [6, 1], [6, 2], nil, [6, 4],
            [6, 5], [6, 6], [6, 7]
          ]
          expect(game.valid_path?(destination, path, all_locations)).to be(true)
          expect(game.checking_opponent?(game.player1, destination)).to be(true)
          expect(game.unblocked_path?(destination, path, all_locations, game.player1)).to be(true)
        end
      end
    end

    context 'when d2 is occupied by a pawn of player two' do
      before do
        game.board.layout[1][3].current_position = nil
        game.board.layout[1][3] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[1][3].current_position = [1, 3]

        game.board.layout[2][2] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][2].current_position = [2, 2]

        allow(game.player2).to receive(:random_destination).and_return([1, 3])
      end

      context 'when the destination is set as e8' do
        destination = [1, 3]
        path = [[1, 3]]
        all_locations = [
          [0, 4], [1, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0], [1, 1],
          [1, 2], nil, [1, 4], [1, 5], [1, 6], [1, 7], [7, 4], [2, 2], [7, 0], [7, 7],
          [7, 2], [7, 5], [7, 1], [7, 6], [6, 0], [6, 1], [6, 2], [6, 3], nil, [6, 5],
          [6, 6], [6, 7]
        ]
        it 'returns true on valid path and false on checking opponent as well as unblocked path' do
          expect(game.valid_path?(destination, path, all_locations)).to be(true)
          expect(game.checking_opponent?(game.player2, destination)).to be(false)
          expect(game.unblocked_path?(destination, path, all_locations, game.player2)).to be(false)
        end

        it 'returns true on checking opponent if the check filter is on' do
          expect(game.checking_opponent?(game.player2, destination, check: true)).to be(true)
        end
      end

      context 'when d2 is occupied by a pawn of player two' do
        before { allow(game.player2).to receive(:random_destination).and_return([6, 4]) }

        context 'when the destination is set as e7 which is occupied by the same player' do
          it 'returns false on valid path and true on checking opponent, and false on unblocked path' do
            destination = [6, 4]
            path = [[7, 6], [6, 4]]
            all_locations = [
              [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [6, 0], [6, 1], [6, 2],
              [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5],
              [0, 1], [0, 6], [1, 0], [1, 1], [1, 2], [1, 3], [3, 4], [1, 5], [1, 6], [1, 7]
            ]
            expect(game.valid_path?(destination, path, all_locations)).to be(false)
            expect(game.checking_opponent?(game.player2, destination)).to be(true)
            expect(game.unblocked_path?(destination, path, all_locations, game.player2)).to be(false)
          end
        end
      end

      context 'when d2 is occupied by a pawn of player two' do
        before do
          locations = [
            [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0],
            [1, 1], [1, 2], nil, [1, 4], [1, 5], [1, 6], [1, 7], [4, 3]
          ]
          allow(game.player1).to receive(:piece_locations).and_return(locations)
        end
        context 'when the destination is set as d5 which is not occupied by the same player' do
          destination = [4, 3]
          path = [[4, 3], [3, 3]]
          all_locations = [
            [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0], [1, 1], [1, 2],
            [1, 3], [3, 4], [1, 5], [1, 6], [1, 7], [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5],
            [7, 1], [7, 6], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [3, 3],
            [4, 3]
          ]

          it 'returns false on valid path, checking opponent and unblocked path' do
            expect(game.valid_path?(destination, path, all_locations)).to be(false)
            expect(game.checking_opponent?(game.player1, destination)).to be(false)
            expect(game.unblocked_path?(destination, path, all_locations, game.player1)).to be(false)
          end

          it 'returns true on checking opponent if the check filter is on' do
            expect(game.checking_opponent?(game.player1, destination, check: true)).to be(true)
          end
        end
      end
    end
  end

  describe '#valid_path?' do
    context 'when all locations have no overlap with path[0...-1] and destination is the same as path[-1]' do
      it 'returns true' do
        path = [[1, 4], [2, 5], [3, 6], [4, 7]]
        all_locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0],
          [1, 1], [1, 2], [1, 3], [3, 4], [1, 5], [1, 6], [1, 7], [7, 4], [7, 3],
          [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [4, 0], [6, 1], [6, 2],
          [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(game.valid_path?([4, 7], path, all_locations)).to be(true)
      end
    end

    context 'when all locations have overlap with path[0...-1] but destination is not the same as path[-1]' do
      it 'returns false' do
        path = [[5, 1], [4, 0]]
        all_locations = [
          [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [6, 0],
          [5, 1], [4, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [0, 4], [0, 3],
          [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0], [1, 1], [1, 2],
          [1, 3], [3, 4], [2, 5], [1, 6], [1, 7]
        ]
        expect(game.valid_path?([5, 1], path, all_locations)).to be(false)
      end
    end

    context 'when all locations have overlap with path[0...-1] and destination is the same as path[-1]' do
      it 'returns false' do
        path = [[0, 6], [1, 4]]
        all_locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6],
          [1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7],
          [7, 4], [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6],
          [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(game.valid_path?([1, 4], path, all_locations)).to be(false)
      end
    end

    context 'when all locations have no overlap with path[0...-1] and destination is not the same as path[-1]' do
      it 'returns false' do
        path = [[1, 4]]
        all_locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6],
          [1, 0], [1, 1], [1, 2], [1, 3], [1, 5], [1, 6], [1, 7], [7, 4],
          [7, 3], [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [6, 0],
          [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(game.valid_path?([7, 4], path, all_locations)).to be(false)
      end
    end

    context 'when there is no destination' do
      it 'returns false' do
        path = [[1, 4], [2, 5], [3, 6], [4, 7]]
        all_locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0],
          [1, 1], [1, 2], [1, 3], [3, 4], [1, 5], [1, 6], [1, 7], [7, 4], [7, 3],
          [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [4, 0], [6, 1], [6, 2],
          [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(game.valid_path?(nil, path, all_locations)).to be(false)
      end
    end

    context 'when there is no path' do
      it 'returns false' do
        all_locations = [
          [0, 4], [0, 3], [0, 0], [0, 7], [0, 2], [0, 5], [0, 1], [0, 6], [1, 0],
          [1, 1], [1, 2], [1, 3], [3, 4], [1, 5], [1, 6], [1, 7], [7, 4], [7, 3],
          [7, 0], [7, 7], [7, 2], [7, 5], [7, 1], [7, 6], [4, 0], [6, 1], [6, 2],
          [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]
        ]
        expect(game.valid_path?([4, 7], [], all_locations)).to be(false)
      end
    end

    context 'when there are no all locations but' do
      it 'returns false' do
        path = [[1, 4], [2, 5], [3, 6], [4, 7]]
        expect(game.valid_path?([4, 7], path, [])).to be(false)
      end
    end
  end

  describe '#checking_opponent?' do
    context 'when e8 is not occupied by the same player' do
      before do
        game.board.layout[6][3].current_position = nil
        game.board.layout[6][3] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][3].current_position = [6, 3]
      end

      context 'when searching a path to e8' do
        it 'returns true' do
          expect(game.checking_opponent?(game.player1, [7, 4])).to be(true)
        end
      end

      context 'when searching a path to e8 and the check filter is on' do
        it 'returns true' do
          expect(game.checking_opponent?(game.player1, [7, 4], check: true)).to be(true)
        end
      end
    end

    context 'when d2 is occupied by a pawn of player two' do
      before do
        game.board.layout[1][3].current_position = nil
        game.board.layout[1][3] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[1][3].current_position = [1, 3]

        game.board.layout[2][2] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][2].current_position = [2, 2]

        allow(game.player2).to receive(:random_destination).and_return([1, 3])
      end
      context 'when searching a path to d2' do
        it 'returns false' do
          expect(game.checking_opponent?(game.player2, [1, 3])).to be(false)
        end
      end

      context 'when searching a path to d2 and the check filter is on' do
        it 'returns true' do
          expect(game.checking_opponent?(game.player2, [1, 3], check: true)).to be(true)
        end
      end
    end
  end

  describe '#valid' do
    context 'when the location is empty' do
      it 'returns true' do
        expect(game.valid?([])).to be(true)
      end
    end

    context 'when the location is within the range' do
      it 'returns true' do
        expect(game.valid?([4, 6])).to be(true)
      end
    end

    context 'when the location is not within the range' do
      it 'returns false' do
        expect(game.valid?([9, 19])).to be(false)
      end
    end

    context 'when the location is not within the range' do
      it 'returns false' do
        expect(game.valid?([3, 7], 0, 6)).to be(false)
      end
    end

    context 'when the location is within the range' do
      it 'returns false' do
        expect(game.valid?([1, 2], 0, 4)).to be(true)
      end
    end
  end

  describe '#empty_path?' do
    context 'when there is no location in the path' do
      it 'returns true' do
        path = [[]]
        expect(game.empty_path?(*path)).to be(true)
      end
    end

    context 'when there is only one locations in the paths' do
      it 'returns false' do
        path = [[4, 5]]
        expect(game.empty_path?(*path)).to be(false)
      end
    end

    context 'when there are overlapping locations in the paths' do
      it 'returns false' do
        path = [[[4, 5], [3, 4]], [[3, 4], [6, 7]]]
        expect(game.empty_path?(*path)).to be(false)
      end
    end

    context 'when there are not overlapping locations in the paths' do
      it 'returns true' do
        path = [[[4, 2], [4, 6]], [[1, 2], [4, 3]]]
        expect(game.empty_path?(*path)).to be(true)
      end
    end

    context 'when there are overlapping locations in the paths' do
      it 'returns false' do
        path = [[[4, 5], [3, 4]], [[3, 4], [6, 7]], [[3, 4], [4, 3], [7, 7]]]
        expect(game.empty_path?(*path)).to be(false)
      end
    end

    context 'when there are overlapping locations in the paths' do
      it 'returns false' do
        path = [[[4, 5], [3, 4], [1, 1]], [[3, 4], [6, 7], [2, 1]], [[4, 5], [5, 5], [6, 6]]]
        expect(game.empty_path?(*path)).to be(true)
      end
    end
  end
end
