RSpec.describe Traceable do
  let(:game) { Game.new }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")

    allow($stdout).to receive(:write)
  end

  describe '#build_path' do

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
        before {allow(game.player2).to receive(:random_destination).and_return([6, 4])}

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
          locations =  [
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
          [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7],
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
