# frozen_string_literal: true

require './lib/updatable'
require './lib/conditionable'
require './lib/traceable'
require './lib/exceptionable'
require './lib/configurable'
require './lib/game'
require './lib/visualizable'

RSpec.describe Configurable do
  let(:game) { Game.new }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")
    allow($stdout).to receive(:write)
  end

  let(:dummy_class) do
    Class.new do
      include Updatable
      include Conditionable
      include Traceable
      include Exceptionable::EnPassant
      include Exceptionable::Check
      include Exceptionable::EnPassant
      include Exceptionable::Castling
      include Configurable
      include Visualizable
    end.new
  end

  describe '#winner?' do
    context 'when the king of player two is captured' do
      before { game.player2.king[0].current_position = nil }
      it 'prints the message stating player one is the winner' do
        msg = "\nPlayer 1 is the winner!"
        expect {game.winner?(game.player1) }.to output(include(msg)).to_stdout
      end

      it 'returns that player one is the winner while player two is not' do
        expect(game.winner?(game.player1)).to be(true)
        expect(game.winner?(game.player2)).to be_nil
      end
    end

    context 'when the current position of the king of the first player is set as nil' do
      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]
      end

      it 'returns true for player one and false for player two' do
        expect(game.win_condition(game.player1)).to be(true)
        expect(game.win_condition(game.player2)).to be(false)
      end
    end
  end

  describe '#win_condition' do
    context 'when the current position of the king of the second player is set as nil' do
      before { game.player2.king[0].current_position = nil }
      it 'returns false for player two and true for player one' do
        expect(game.win_condition(game.player2)).to be(false)
        expect(game.win_condition(game.player1)).to be(true)
      end
    end

    context 'when the current position of the king of the first player is set as nil' do
      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]
      end

      it 'returns true for player one and false for player two' do
        expect(game.win_condition(game.player1)).to be(true)
        expect(game.win_condition(game.player2)).to be(false)
      end
    end

    context 'when there is no win condition' do
      it 'returns false for player two and true for player one' do
        expect(game.win_condition(game.player1)).to be(false)
        expect(game.win_condition(game.player2)).to be(false)
      end
    end
  end

  describe '#king_captured?' do
    context 'when the king of the second player is examined at the beginning' do
      it 'returns false' do
        expect(game.king_captured?(game.player1)).to be(false)
      end
    end

    context 'when the king of the first player is examined at the beginning' do
      it 'returns false' do
        expect(game.king_captured?(game.player2)).to be(false)
      end
    end

    context 'when the current position of the king of the first player is set as nil' do
      before { game.player1.king[0].current_position = nil }
      it 'returns true' do
        expect(game.king_captured?(game.player2)).to be(true)
      end
    end

    context 'when the current position of the king of the second player is set as nil' do
      before { game.player2.king[0].current_position = nil }
      it 'returns true' do
        expect(game.king_captured?(game.player1)).to be(true)
      end
    end
  end

end
